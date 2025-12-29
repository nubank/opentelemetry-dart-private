// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

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
