// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../metric_data.dart';
import 'metric_exporter.dart';

class ConsoleMetricExporter implements MetricExporter {
  var _isShutdown = false;

  void _printMetrics(List<MetricData> metrics) {
    for (final metric in metrics) {
      print({
        'name': metric.descriptor.name,
        'description': metric.descriptor.description,
        'unit': metric.descriptor.unit,
        'type': metric.descriptor.type.toString(),
        'aggregation': metric.aggregationType.toString(),
        'resource': metric.resource.attributes.keys.map((key) => {
              'key': key,
              'value': metric.resource.attributes.get(key),
            }),
        'instrumentationScope': {
          'name': metric.instrumentationScope.name,
          'version': metric.instrumentationScope.version,
        },
        'dataPoints': metric.dataPoints.map((dp) => {
              'value': dp.value,
              'timestamp': dp.timestamp,
              'attributes': dp.attributes.map((attr) => {
                    'key': attr.key,
                    'value': attr.value,
                  }),
            }),
        'histogramDataPoints': metric.histogramDataPoints.map((hdp) => {
              'count': hdp.count,
              'sum': hdp.sum,
              'min': hdp.min,
              'max': hdp.max,
              'timestamp': hdp.timestamp,
              'buckets': hdp.buckets.map((b) => {
                    'lowerBound': b.lowerBound,
                    'upperBound': b.upperBound,
                    'count': b.count,
                  }),
              'attributes': hdp.attributes.map((attr) => {
                    'key': attr.key,
                    'value': attr.value,
                  }),
            }),
      });
    }
  }

  @override
  void export(List<MetricData> metrics) {
    if (_isShutdown) {
      return;
    }
    _printMetrics(metrics);
  }

  @override
  void forceFlush() {
    // Console exporter exports immediately
  }

  @override
  void shutdown() {
    _isShutdown = true;
  }
}
