// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../../../../api.dart' as api;

/// Decision for metric recording
enum MetricFilterDecision {
  /// Drop the measurement - it will not be recorded
  drop,

  /// Record the measurement
  record,
}

/// Result of a metric filter decision
class MetricFilterResult {
  final MetricFilterDecision decision;
  final List<api.Attribute> attributes;

  MetricFilterResult(this.decision, this.attributes);
}

/// Represents an entity which determines whether a metric measurement should be recorded.
abstract class MetricFilter {
  /// Determines whether a metric measurement should be recorded.
  ///
  /// [instrumentName] The name of the metric instrument
  /// [value] The measurement value
  /// [attributes] The measurement attributes
  /// [context] The current context
  MetricFilterResult shouldRecord(
    String instrumentName,
    num value,
    List<api.Attribute> attributes,
    api.Context? context,
  );

  String get description;
}
