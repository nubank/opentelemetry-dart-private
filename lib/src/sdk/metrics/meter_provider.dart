// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:meta/meta.dart';
import 'package:logging/logging.dart';
import 'package:quiver/core.dart';
import '../../../api.dart' as api;
import '../../../sdk.dart' as sdk;
import '../../api/metrics/meter.dart' as api_meter;
import '../../api/metrics/meter_provider.dart' as api_meter_provider;
import '../common/instrumentation_scope.dart';
import 'meter.dart';
import 'metric_data.dart';
import 'readers/metric_reader.dart';

class MeterProviderImpl implements api_meter_provider.MeterProvider {
  final _logger = Logger('opentelemetry.sdk.metrics.meterprovider');

  @protected
  final Map<int, MeterImpl> meters = {};

  @visibleForTesting
  final sdk.Resource resource;

  final sdk.TimeProvider _timeProvider;
  final sdk.MetricFilter _filter;
  final List<MetricReader> _readers = [];

  MeterProviderImpl({
    sdk.Resource? resource,
    sdk.TimeProvider? timeProvider,
    sdk.MetricFilter? filter,
    List<MetricReader>? readers,
  })  : resource = resource ?? sdk.Resource([]),
        _timeProvider = timeProvider ?? sdk.DateTimeTimeProvider(),
        _filter = filter ?? const sdk.AlwaysRecordFilter() {
    if (readers != null) {
      _readers.addAll(readers);
    }
  }

  @override
  api_meter.Meter get(String name,
      {String version = '',
      String schemaUrl = '',
      List<api.Attribute> attributes = const []}) {
    if (name.isEmpty) {
      _logger.warning('Invalid Meter Name', '', StackTrace.current);
    }

    return meters.putIfAbsent(
      hash3(name, version, schemaUrl),
      () => MeterImpl(
        resource,
        InstrumentationScope(name, version, schemaUrl, attributes),
        _timeProvider,
        _filter,
      ),
    );
  }

  void addMetricReader(MetricReader reader) {
    _readers.add(reader);
  }

  List<MetricData> collectAllMetrics() {
    final allMetrics = <MetricData>[];
    for (final meter in meters.values) {
      allMetrics.addAll(meter.collectMetrics());
    }
    return allMetrics;
  }

  void forceFlush() {
    for (final reader in _readers) {
      reader.forceFlush();
    }
  }

  void shutdown() {
    for (final reader in _readers) {
      reader.shutdown();
    }
  }
}
