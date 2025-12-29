// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart' as api;
import '../up_down_counter.dart';

class NoopUpDownCounter<T extends num> implements UpDownCounter<T> {
  @override
  void add(T value, {List<api.Attribute>? attributes, api.Context? context}) {}
}
