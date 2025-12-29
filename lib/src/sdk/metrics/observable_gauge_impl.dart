import 'package:opentelemetry/api.dart' as api;
import '../../../sdk.dart' as sdk;
import '../../api/metrics/observable_gauge.dart' as api_observable;
import 'metric_data.dart';

class ObservableGaugeImpl<T extends num>
    implements api_observable.ObservableGauge<T> {
  final String _name;
  final String? _description;
  final String? _unit;
  final sdk.TimeProvider _timeProvider;
  final sdk.MetricFilter _filter;
  final api_observable.ObservableCallback<T> _callback;
  final Map<String, T> _observations = {};
  final Map<String, List<api.Attribute>> _attributes = {};

  ObservableGaugeImpl(
    this._name,
    this._callback,
    this._timeProvider,
    this._filter, {
    String? description,
    String? unit,
  })  : _description = description,
        _unit = unit;

  void collect() {
    _observations.clear();
    _attributes.clear();
    _callback(_ObservableResultImpl<T>(this));
  }

  void _observe(T value, List<api.Attribute> attributes) {
    // Apply filter decision
    final filterResult = _filter.shouldRecord(_name, value, attributes, null);

    // Drop the measurement if filter decision says so
    if (filterResult.decision == sdk.MetricFilterDecision.drop) {
      return;
    }

    final attrKey = _attributesKey(filterResult.attributes);
    _observations[attrKey] = value;
    _attributes[attrKey] = filterResult.attributes;
  }

  String _attributesKey(List<api.Attribute> attributes) {
    if (attributes.isEmpty) return '__empty__';
    final sorted = List<api.Attribute>.from(attributes)
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((a) => '${a.key}=${a.value}').join(',');
  }

  List<MetricDataPoint<T>> collectDataPoints() {
    collect();
    final dataPoints = <MetricDataPoint<T>>[];
    for (final entry in _observations.entries) {
      dataPoints.add(MetricDataPoint<T>(
        attributes: _attributes[entry.key] ?? [],
        value: entry.value,
        timestamp: _timeProvider.now,
      ));
    }
    return dataPoints;
  }

  MetricDescriptor get descriptor => MetricDescriptor(
        name: _name,
        description: _description,
        unit: _unit,
        type: InstrumentType.observableGauge,
      );
}

class _ObservableResultImpl<T extends num>
    implements api_observable.ObservableResult<T> {
  final ObservableGaugeImpl<T> _gauge;

  _ObservableResultImpl(this._gauge);

  @override
  void observe(T value, {List<api.Attribute>? attributes}) {
    _gauge._observe(value, attributes ?? []);
  }
}
