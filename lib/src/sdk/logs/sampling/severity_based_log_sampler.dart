// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import '../../../../api.dart' as api;
import '../../../../sdk.dart' as sdk;
import '../../../api/logs/log_record.dart';

/// A sampler that samples log records based on severity level.
/// Only logs with severity >= minSeverity will be sampled.
class SeverityBasedLogSampler implements sdk.LogRecordSampler {
  final SeverityNumber minSeverity;

  const SeverityBasedLogSampler(this.minSeverity);

  @override
  String get description =>
      'SeverityBasedLogSampler{minSeverity=${minSeverity.name}}';

  @override
  sdk.LogSamplingResult shouldSample(
    api.Context? context,
    Int64 timestamp,
    SeverityNumber severityNumber,
    String? severityText,
    dynamic body,
    List<api.Attribute> attributes,
  ) {
    final decision = severityNumber.value >= minSeverity.value
        ? sdk.LogSamplingDecision.recordAndSample
        : sdk.LogSamplingDecision.drop;

    return sdk.LogSamplingResult(decision, attributes);
  }
}
