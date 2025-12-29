// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:async';
import 'dart:math';
import 'package:fixnum/fixnum.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../../../../sdk.dart' as sdk;
import '../../proto/opentelemetry/proto/collector/logs/v1/logs_service.pb.dart'
    as pb_logs_service;
import '../../proto/opentelemetry/proto/common/v1/common.pb.dart' as pb_common;
import '../../proto/opentelemetry/proto/logs/v1/logs.pb.dart' as pb_logs;
import '../../proto/opentelemetry/proto/resource/v1/resource.pb.dart'
    as pb_resource;
import 'log_exporter.dart';
import '../read_only_log_record.dart';

class OtlpLogRecordExporter implements LogRecordExporter {
  final Logger _log = Logger('opentelemetry.OtlpLogRecordExporter');

  final Uri uri;
  final http.Client client;
  final Map<String, String> headers;
  final int timeoutMilliseconds;
  var _isShutdown = false;

  OtlpLogRecordExporter(
    this.uri, {
    http.Client? httpClient,
    this.headers = const {},
    this.timeoutMilliseconds = 10000,
  }) : client = httpClient ?? http.Client();

  @override
  void export(List<ReadOnlyLogRecord> logRecords) {
    if (_isShutdown) {
      return;
    }

    if (logRecords.isEmpty) {
      return;
    }

    unawaited(_send(uri, logRecords));
  }

  Future<void> _send(Uri uri, List<ReadOnlyLogRecord> logRecords) async {
    const maxRetries = 3;
    var retries = 0;
    const validRetryCodes = [429, 502, 503, 504];

    final body = pb_logs_service.ExportLogsServiceRequest(
      resourceLogs: _logsToProtobuf(logRecords),
    );
    final headers = {'Content-Type': 'application/x-protobuf'}
      ..addAll(this.headers);

    while (retries < maxRetries) {
      try {
        final request =
            client.post(uri, body: body.writeToBuffer(), headers: headers);
        final response = timeoutMilliseconds > 0
            ? await request.timeout(Duration(milliseconds: timeoutMilliseconds))
            : await request;

        if (response.statusCode == 200) {
          return;
        }

        _log.warning('Failed to export ${logRecords.length} log records. '
            'HTTP status code: ${response.statusCode}');

        if (!validRetryCodes.contains(response.statusCode)) {
          return;
        }
      } catch (e) {
        _log.warning('Failed to export ${logRecords.length} log records. $e');
        return;
      }

      final delay =
          _calculateJitteredDelay(retries++, Duration(milliseconds: 100));
      await Future.delayed(delay);
    }

    _log.severe(
      'Failed to export ${logRecords.length} log records after $maxRetries retries',
    );
  }

  Duration _calculateJitteredDelay(int retries, Duration baseDelay) {
    final delay = baseDelay.inMilliseconds * pow(2, retries);
    final jitter = Random().nextDouble() * delay;
    return Duration(milliseconds: (delay + jitter).toInt());
  }

  Iterable<pb_logs.ResourceLogs> _logsToProtobuf(List<ReadOnlyLogRecord> logs) {
    final resourceMap = <sdk.Resource,
        Map<sdk.InstrumentationScope, List<pb_logs.LogRecord>>>{};

    for (final log in logs) {
      final scopeMap = resourceMap[log.resource] ??
          <sdk.InstrumentationScope, List<pb_logs.LogRecord>>{};
      scopeMap[log.instrumentationScope] =
          scopeMap[log.instrumentationScope] ?? <pb_logs.LogRecord>[]
            ..add(_logToProtobuf(log));
      resourceMap[log.resource] = scopeMap;
    }

    final resourceLogs = <pb_logs.ResourceLogs>[];
    for (final entry in resourceMap.entries) {
      final attrs = <pb_common.KeyValue>[];
      for (final key in entry.key.attributes.keys) {
        attrs.add(pb_common.KeyValue(
          key: key,
          value: _attributeValueToProtobuf(entry.key.attributes.get(key)!),
        ));
      }

      final resourceLog = pb_logs.ResourceLogs(
        resource: pb_resource.Resource(attributes: attrs),
        scopeLogs: [],
      );

      for (final scopeEntry in entry.value.entries) {
        resourceLog.scopeLogs.add(pb_logs.ScopeLogs(
          scope: pb_common.InstrumentationScope(
            name: scopeEntry.key.name,
            version: scopeEntry.key.version,
          ),
          logRecords: scopeEntry.value,
        ));
      }

      resourceLogs.add(resourceLog);
    }

    return resourceLogs;
  }

  pb_logs.LogRecord _logToProtobuf(ReadOnlyLogRecord log) {
    return pb_logs.LogRecord(
      timeUnixNano: log.timestamp,
      observedTimeUnixNano: log.observedTimestamp ?? log.timestamp,
      severityNumber:
          pb_logs.SeverityNumber.valueOf(log.severityNumber.value) ??
              pb_logs.SeverityNumber.SEVERITY_NUMBER_UNSPECIFIED,
      severityText: log.severityText ?? '',
      body: _anyValueToProtobuf(log.body),
      attributes: log.attributesMap.keys.map((key) => pb_common.KeyValue(
            key: key,
            value: _attributeValueToProtobuf(log.attributesMap.get(key)!),
          )),
      droppedAttributesCount: log.droppedAttributesCount,
      flags: log.traceFlags ?? 0,
      traceId: log.traceId?.get() ?? List.filled(16, 0),
      spanId: log.spanId?.get() ?? List.filled(8, 0),
    );
  }

  pb_common.AnyValue _anyValueToProtobuf(dynamic value) {
    if (value == null) {
      return pb_common.AnyValue();
    }
    return _attributeValueToProtobuf(value);
  }

  pb_common.AnyValue _attributeValueToProtobuf(Object value) {
    switch (value.runtimeType) {
      case String:
        return pb_common.AnyValue(stringValue: value as String);
      case bool:
        return pb_common.AnyValue(boolValue: value as bool);
      case double:
        return pb_common.AnyValue(doubleValue: value as double);
      case int:
        return pb_common.AnyValue(intValue: Int64(value as int));
      case List:
        final list = value as List;
        if (list.isNotEmpty) {
          final values = list.map((item) => _anyValueToProtobuf(item)).toList();
          return pb_common.AnyValue(
            arrayValue: pb_common.ArrayValue(values: values),
          );
        }
    }
    return pb_common.AnyValue();
  }

  @override
  void shutdown() {
    _isShutdown = true;
    client.close();
  }
}
