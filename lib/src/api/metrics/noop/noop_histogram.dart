// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart' as api;
import '../histogram.dart';

class NoopHistogram<T extends num> implements Histogram<T> {
  @override
  void record(T value,
      {List<api.Attribute>? attributes, api.Context? context}) {}
}
