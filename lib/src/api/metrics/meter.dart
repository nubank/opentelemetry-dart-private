import 'counter.dart';
import 'up_down_counter.dart';
import 'histogram.dart';
import 'observable_gauge.dart';

/// Meter is the interface for creating metric instruments
abstract class Meter {
  /// Creates a new [Counter] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// See https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#instrument-naming-rule
  Counter<T> createCounter<T extends num>(String name,
      {String? description, String? unit});

  /// Creates a new [UpDownCounter] instrument. UpDownCounter can increase and decrease,
  /// and is used for values that can go up and down (e.g., queue size, active requests).
  UpDownCounter<T> createUpDownCounter<T extends num>(String name,
      {String? description, String? unit});

  /// Creates a new [Histogram] instrument. Histograms are used to record distributions
  /// of values (e.g., request duration, response size).
  Histogram<T> createHistogram<T extends num>(String name,
      {String? description, String? unit});

  /// Creates a new [ObservableGauge] instrument. Observable gauges are used for values
  /// that are observed at a point in time (e.g., CPU usage, memory usage).
  ObservableGauge<T> createObservableGauge<T extends num>(
    String name,
    ObservableCallback<T> callback, {
    String? description,
    String? unit,
  });
}
