import '../counter.dart';
import '../histogram.dart';
import '../meter.dart';
import '../observable_gauge.dart';
import '../up_down_counter.dart';
import 'noop_counter.dart';
import 'noop_histogram.dart';
import 'noop_observable_gauge.dart';
import 'noop_up_down_counter.dart';

/// A no-op instance of a [Meter]
class NoopMeter implements Meter {
  @override
  Counter<T> createCounter<T extends num>(String name,
      {String? description, String? unit}) {
    return NoopCounter<T>();
  }

  @override
  UpDownCounter<T> createUpDownCounter<T extends num>(String name,
      {String? description, String? unit}) {
    return NoopUpDownCounter<T>();
  }

  @override
  Histogram<T> createHistogram<T extends num>(String name,
      {String? description, String? unit}) {
    return NoopHistogram<T>();
  }

  @override
  ObservableGauge<T> createObservableGauge<T extends num>(
    String name,
    ObservableCallback<T> callback, {
    String? description,
    String? unit,
  }) {
    return NoopObservableGauge<T>();
  }
}
