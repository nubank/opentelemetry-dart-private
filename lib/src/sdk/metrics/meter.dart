// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:meta/meta.dart';
import '../../../sdk.dart' as sdk;
import '../../api/metrics/counter.dart' as api_counter;
import '../../api/metrics/up_down_counter.dart' as api_up_down_counter;
import '../../api/metrics/histogram.dart' as api_histogram;
import '../../api/metrics/observable_gauge.dart' as api_observable;
import '../../api/metrics/meter.dart' as api_meter;
import 'counter.dart';
import 'up_down_counter_impl.dart';
import 'histogram_impl.dart';
import 'observable_gauge_impl.dart';
import 'metric_data.dart';

class MeterImpl implements api_meter.Meter {
  final sdk.Resource _resource;
  final sdk.InstrumentationScope _instrumentationScope;
  final sdk.TimeProvider _timeProvider;
  final sdk.MetricFilter _filter;
  final List<dynamic> _instruments = [];

  @protected
  MeterImpl(
    this._resource,
    this._instrumentationScope,
    this._timeProvider,
    this._filter,
  );

  @override
  api_counter.Counter<T> createCounter<T extends num>(String name,
      {String? description, String? unit}) {
    final counter = CounterImpl<T>(name, _timeProvider, _filter,
        description: description, unit: unit);
    _instruments.add(counter);
    return counter;
  }

  @override
  api_up_down_counter.UpDownCounter<T> createUpDownCounter<T extends num>(
      String name,
      {String? description,
      String? unit}) {
    final upDownCounter = UpDownCounterImpl<T>(name, _timeProvider, _filter,
        description: description, unit: unit);
    _instruments.add(upDownCounter);
    return upDownCounter;
  }

  @override
  api_histogram.Histogram<T> createHistogram<T extends num>(String name,
      {String? description, String? unit}) {
    final histogram = HistogramImpl<T>(name, _timeProvider, _filter,
        description: description, unit: unit);
    _instruments.add(histogram);
    return histogram;
  }

  @override
  api_observable.ObservableGauge<T> createObservableGauge<T extends num>(
    String name,
    api_observable.ObservableCallback<T> callback, {
    String? description,
    String? unit,
  }) {
    final gauge = ObservableGaugeImpl<T>(name, callback, _timeProvider, _filter,
        description: description, unit: unit);
    _instruments.add(gauge);
    return gauge;
  }

  List<MetricData> collectMetrics() {
    final metrics = <MetricData>[];
    for (final instrument in _instruments) {
      if (instrument is CounterImpl) {
        final dataPoints = instrument.collectDataPoints();
        if (dataPoints.isNotEmpty) {
          metrics.add(MetricData(
            descriptor: instrument.descriptor,
            resource: _resource,
            instrumentationScope: _instrumentationScope,
            dataPoints: dataPoints,
            aggregationType: AggregationType.sum,
          ));
        }
      } else if (instrument is UpDownCounterImpl) {
        final dataPoints = instrument.collectDataPoints();
        if (dataPoints.isNotEmpty) {
          metrics.add(MetricData(
            descriptor: instrument.descriptor,
            resource: _resource,
            instrumentationScope: _instrumentationScope,
            dataPoints: dataPoints,
            aggregationType: AggregationType.sum,
          ));
        }
      } else if (instrument is HistogramImpl) {
        final histogramDataPoints = instrument.collectHistogramDataPoints();
        if (histogramDataPoints.isNotEmpty) {
          metrics.add(MetricData(
            descriptor: instrument.descriptor,
            resource: _resource,
            instrumentationScope: _instrumentationScope,
            histogramDataPoints: histogramDataPoints,
            aggregationType: AggregationType.histogram,
          ));
        }
      } else if (instrument is ObservableGaugeImpl) {
        final dataPoints = instrument.collectDataPoints();
        if (dataPoints.isNotEmpty) {
          metrics.add(MetricData(
            descriptor: instrument.descriptor,
            resource: _resource,
            instrumentationScope: _instrumentationScope,
            dataPoints: dataPoints,
            aggregationType: AggregationType.lastValue,
          ));
        }
      }
    }
    return metrics;
  }
}
