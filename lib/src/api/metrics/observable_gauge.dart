import 'package:opentelemetry/api.dart';

/// Callback function for observable instruments
typedef ObservableCallback<T extends num> = void Function(
    ObservableResult<T> result);

/// Result interface for observable instrument callbacks
abstract class ObservableResult<T extends num> {
  /// Observe a value with attributes
  void observe(T value, {List<Attribute>? attributes});
}

/// Observable Gauge instrument
abstract class ObservableGauge<T extends num> {
  // Observable instruments don't have explicit record methods
  // They are read by the metric reader via callbacks
}
