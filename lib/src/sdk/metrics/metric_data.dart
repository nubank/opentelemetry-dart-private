import 'package:fixnum/fixnum.dart';
import '../../../sdk.dart' as sdk;
import '../../api/common/attribute.dart';

/// Types of metric instruments
enum InstrumentType {
  counter,
  upDownCounter,
  histogram,
  observableGauge,
}

/// Aggregation types for metrics
enum AggregationType {
  sum,
  lastValue,
  histogram,
}

/// Metric descriptor containing metadata about a metric
class MetricDescriptor {
  final String name;
  final String? description;
  final String? unit;
  final InstrumentType type;

  MetricDescriptor({
    required this.name,
    this.description,
    this.unit,
    required this.type,
  });
}

/// A data point representing a metric measurement
class MetricDataPoint<T extends num> {
  final List<Attribute> attributes;
  final T value;
  final Int64 timestamp;
  final Int64? startTimestamp;

  MetricDataPoint({
    required this.attributes,
    required this.value,
    required this.timestamp,
    this.startTimestamp,
  });
}

/// Histogram bucket
class HistogramBucket {
  final double lowerBound;
  final double upperBound;
  final int count;

  HistogramBucket({
    required this.lowerBound,
    required this.upperBound,
    required this.count,
  });
}

/// Histogram data point
class HistogramDataPoint {
  final List<Attribute> attributes;
  final Int64 timestamp;
  final Int64? startTimestamp;
  final int count;
  final num sum;
  final num? min;
  final num? max;
  final List<HistogramBucket> buckets;

  HistogramDataPoint({
    required this.attributes,
    required this.timestamp,
    this.startTimestamp,
    required this.count,
    required this.sum,
    this.min,
    this.max,
    required this.buckets,
  });
}

/// Collected metric data ready for export
class MetricData {
  final MetricDescriptor descriptor;
  final sdk.Resource resource;
  final sdk.InstrumentationScope instrumentationScope;
  final List<MetricDataPoint> dataPoints;
  final List<HistogramDataPoint> histogramDataPoints;
  final AggregationType aggregationType;

  MetricData({
    required this.descriptor,
    required this.resource,
    required this.instrumentationScope,
    this.dataPoints = const [],
    this.histogramDataPoints = const [],
    required this.aggregationType,
  });
}
