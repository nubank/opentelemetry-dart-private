// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:logging/logging.dart';
import '../metric_data.dart';
import '../exporters/metric_exporter.dart';
import 'metric_reader.dart';

/// A MetricReader that collects and exports metrics on-demand
class ManualMetricReader implements MetricReader {
  final Logger _log = Logger('opentelemetry.ManualMetricReader');
  final List<MetricExporter> _exporters = [];
  final List<MetricData> Function() _collectCallback;
  bool _isShutdown = false;

  ManualMetricReader(this._collectCallback);

  @override
  List<MetricData> collect() {
    if (_isShutdown) {
      return [];
    }
    return _collectCallback();
  }

  @override
  void registerExporter(MetricExporter exporter) {
    if (_isShutdown) {
      _log.warning('Cannot register exporter on shutdown reader');
      return;
    }
    _exporters.add(exporter);
  }

  @override
  void forceFlush() {
    if (_isShutdown) {
      return;
    }

    final metrics = collect();
    if (metrics.isEmpty) {
      return;
    }

    for (final exporter in _exporters) {
      try {
        exporter.export(metrics);
      } catch (e) {
        _log.warning('Failed to export metrics: $e');
      }
    }
  }

  @override
  void shutdown() {
    if (_isShutdown) {
      return;
    }
    forceFlush();
    _isShutdown = true;
    for (final exporter in _exporters) {
      exporter.shutdown();
    }
  }
}
