import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart' as api;
import '../../../sdk.dart' as sdk;
import '../../api/metrics/up_down_counter.dart' as api_up_down_counter;
import 'metric_data.dart';

class UpDownCounterImpl<T extends num>
    implements api_up_down_counter.UpDownCounter<T> {
  final String _name;
  final String? _description;
  final String? _unit;
  final sdk.TimeProvider _timeProvider;
  final sdk.MetricFilter _filter;
  final Map<String, T> _measurements = {};
  final Map<String, List<api.Attribute>> _attributes = {};
  final Map<String, Int64> _timestamps = {};

  UpDownCounterImpl(
    this._name,
    this._timeProvider,
    this._filter, {
    String? description,
    String? unit,
  })  : _description = description,
        _unit = unit;

  @override
  void add(T value, {List<api.Attribute>? attributes, api.Context? context}) {
    final effectiveAttributes = attributes ?? [];

    // Apply filter decision
    final filterResult =
        _filter.shouldRecord(_name, value, effectiveAttributes, context);

    // Drop the measurement if filter decision says so
    if (filterResult.decision == sdk.MetricFilterDecision.drop) {
      return;
    }

    final attrKey = _attributesKey(filterResult.attributes);
    _measurements[attrKey] = (_measurements[attrKey] ?? 0 as T) + value as T;
    _attributes[attrKey] = filterResult.attributes;
    _timestamps[attrKey] = _timeProvider.now;
  }

  String _attributesKey(List<api.Attribute> attributes) {
    if (attributes.isEmpty) return '__empty__';
    final sorted = List<api.Attribute>.from(attributes)
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((a) => '${a.key}=${a.value}').join(',');
  }

  List<MetricDataPoint<T>> collectDataPoints() {
    final dataPoints = <MetricDataPoint<T>>[];
    for (final entry in _measurements.entries) {
      dataPoints.add(MetricDataPoint<T>(
        attributes: _attributes[entry.key] ?? [],
        value: entry.value,
        timestamp: _timestamps[entry.key] ?? _timeProvider.now,
      ));
    }
    return dataPoints;
  }

  MetricDescriptor get descriptor => MetricDescriptor(
        name: _name,
        description: _description,
        unit: _unit,
        type: InstrumentType.upDownCounter,
      );
}
