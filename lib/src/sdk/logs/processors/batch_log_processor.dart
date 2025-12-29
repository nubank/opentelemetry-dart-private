// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:async';
import 'dart:math';
import 'package:logging/logging.dart';
import '../../../../api.dart' as api;
import '../exporters/log_exporter.dart';
import 'log_processor.dart';
import '../read_only_log_record.dart';

class BatchLogRecordProcessor implements LogRecordProcessor {
  static const int _DEFAULT_MAXIMUM_BATCH_SIZE = 512;
  static const int _DEFAULT_MAXIMUM_QUEUE_SIZE = 2048;
  static const int _DEFAULT_EXPORT_DELAY = 5000;

  final LogRecordExporter _exporter;
  final Logger _log = Logger('opentelemetry.BatchLogRecordProcessor');
  final int _maxExportBatchSize;
  final int _maxQueueSize;
  final List<ReadOnlyLogRecord> _logBuffer = [];

  late final Timer _timer;
  bool _isShutdown = false;

  BatchLogRecordProcessor(
    this._exporter, {
    int maxExportBatchSize = _DEFAULT_MAXIMUM_BATCH_SIZE,
    int scheduledDelayMillis = _DEFAULT_EXPORT_DELAY,
  })  : _maxExportBatchSize = maxExportBatchSize,
        _maxQueueSize = _DEFAULT_MAXIMUM_QUEUE_SIZE {
    _timer = Timer.periodic(
      Duration(milliseconds: scheduledDelayMillis),
      _exportBatch,
    );
  }

  @override
  void onEmit(ReadOnlyLogRecord logRecord, api.Context? context) {
    if (_isShutdown) {
      return;
    }
    _addToBuffer(logRecord);
  }

  @override
  void forceFlush() {
    if (_isShutdown) {
      return;
    }
    while (_logBuffer.isNotEmpty) {
      _exportBatch(_timer);
    }
  }

  @override
  void shutdown() {
    forceFlush();
    _isShutdown = true;
    _timer.cancel();
    _exporter.shutdown();
  }

  void _addToBuffer(ReadOnlyLogRecord logRecord) {
    if (_logBuffer.length >= _maxQueueSize) {
      _log.warning(
        'Max queue size exceeded. Dropping ${_logBuffer.length} log records.',
      );
      return;
    }
    _logBuffer.add(logRecord);
  }

  void _exportBatch(Timer timer) {
    if (_logBuffer.isEmpty) {
      return;
    }

    final batchSize = min(_logBuffer.length, _maxExportBatchSize);
    final batch = _logBuffer.sublist(0, batchSize);
    _logBuffer.removeRange(0, batchSize);

    _exporter.export(batch);
  }
}
