// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:math' as math;
import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart' as api;
import '../../../sdk.dart' as sdk;
import '../../api/metrics/histogram.dart' as api_histogram;
import 'metric_data.dart';

class HistogramImpl<T extends num> implements api_histogram.Histogram<T> {
  final String _name;
  final String? _description;
  final String? _unit;
  final sdk.TimeProvider _timeProvider;
  final sdk.MetricFilter _filter;
  final Map<String, List<T>> _measurements = {};
  final Map<String, List<api.Attribute>> _attributes = {};
  final Map<String, Int64> _timestamps = {};

  // Default histogram buckets
  static const List<double> _defaultBoundaries = [
    0,
    5,
    10,
    25,
    50,
    75,
    100,
    250,
    500,
    1000,
    2500,
    5000,
    7500,
    10000
  ];

  HistogramImpl(
    this._name,
    this._timeProvider,
    this._filter, {
    String? description,
    String? unit,
  })  : _description = description,
        _unit = unit;

  @override
  void record(T value,
      {List<api.Attribute>? attributes, api.Context? context}) {
    final effectiveAttributes = attributes ?? [];

    // Apply filter decision
    final filterResult =
        _filter.shouldRecord(_name, value, effectiveAttributes, context);

    // Drop the measurement if filter decision says so
    if (filterResult.decision == sdk.MetricFilterDecision.drop) {
      return;
    }

    final attrKey = _attributesKey(filterResult.attributes);
    _measurements.putIfAbsent(attrKey, () => []).add(value);
    _attributes[attrKey] = filterResult.attributes;
    _timestamps[attrKey] = _timeProvider.now;
  }

  String _attributesKey(List<api.Attribute> attributes) {
    if (attributes.isEmpty) return '__empty__';
    final sorted = List<api.Attribute>.from(attributes)
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((a) => '${a.key}=${a.value}').join(',');
  }

  List<HistogramDataPoint> collectHistogramDataPoints() {
    final dataPoints = <HistogramDataPoint>[];
    for (final entry in _measurements.entries) {
      final values = entry.value;
      if (values.isEmpty) continue;

      final buckets = _createBuckets(values);
      final sum = values.fold<num>(0, (sum, v) => sum + v);
      final min = values.reduce((a, b) => math.min(a, b));
      final max = values.reduce((a, b) => math.max(a, b));

      dataPoints.add(HistogramDataPoint(
        attributes: _attributes[entry.key] ?? [],
        timestamp: _timestamps[entry.key] ?? _timeProvider.now,
        count: values.length,
        sum: sum,
        min: min,
        max: max,
        buckets: buckets,
      ));
    }
    return dataPoints;
  }

  List<HistogramBucket> _createBuckets(List<T> values) {
    final buckets = <HistogramBucket>[];
    for (var i = 0; i < _defaultBoundaries.length - 1; i++) {
      final lower = _defaultBoundaries[i];
      final upper = _defaultBoundaries[i + 1];
      final count = values.where((v) => v >= lower && v < upper).length;
      buckets.add(HistogramBucket(
        lowerBound: lower,
        upperBound: upper,
        count: count,
      ));
    }
    return buckets;
  }

  MetricDescriptor get descriptor => MetricDescriptor(
        name: _name,
        description: _description,
        unit: _unit,
        type: InstrumentType.histogram,
      );
}
