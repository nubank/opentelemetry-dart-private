// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:async';
import 'package:logging/logging.dart';
import '../metric_data.dart';
import '../exporters/metric_exporter.dart';
import 'metric_reader.dart';

/// A MetricReader that periodically collects and exports metrics
class PeriodicMetricReader implements MetricReader {
  static const int _DEFAULT_EXPORT_INTERVAL = 60000; // 60 seconds

  final Logger _log = Logger('opentelemetry.PeriodicMetricReader');
  final List<MetricExporter> _exporters = [];
  final List<MetricData> Function() _collectCallback;
  late final Timer _timer;
  bool _isShutdown = false;

  PeriodicMetricReader(
    this._collectCallback, {
    int exportIntervalMillis = _DEFAULT_EXPORT_INTERVAL,
  }) {
    _timer = Timer.periodic(
      Duration(milliseconds: exportIntervalMillis),
      (_) => _export(),
    );
  }

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
    _export();
  }

  @override
  void shutdown() {
    if (_isShutdown) {
      return;
    }
    forceFlush();
    _isShutdown = true;
    _timer.cancel();
    for (final exporter in _exporters) {
      exporter.shutdown();
    }
  }

  void _export() {
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
}
