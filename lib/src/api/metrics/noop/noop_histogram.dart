import 'package:opentelemetry/api.dart' as api;
import '../histogram.dart';

class NoopHistogram<T extends num> implements Histogram<T> {
  @override
  void record(T value,
      {List<api.Attribute>? attributes, api.Context? context}) {}
}
