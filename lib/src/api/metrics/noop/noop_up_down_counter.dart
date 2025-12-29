import 'package:opentelemetry/api.dart' as api;
import '../up_down_counter.dart';

class NoopUpDownCounter<T extends num> implements UpDownCounter<T> {
  @override
  void add(T value, {List<api.Attribute>? attributes, api.Context? context}) {}
}
