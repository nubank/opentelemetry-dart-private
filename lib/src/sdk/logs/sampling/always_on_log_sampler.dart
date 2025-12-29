// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import '../../../../api.dart' as api;
import '../../../../sdk.dart' as sdk;
import '../../../api/logs/log_record.dart';

/// A sampler that always samples log records.
class AlwaysOnLogSampler implements sdk.LogRecordSampler {
  const AlwaysOnLogSampler();

  @override
  String get description => 'AlwaysOnLogSampler';

  @override
  sdk.LogSamplingResult shouldSample(
    api.Context? context,
    Int64 timestamp,
    SeverityNumber severityNumber,
    String? severityText,
    dynamic body,
    List<api.Attribute> attributes,
  ) {
    return sdk.LogSamplingResult(
        sdk.LogSamplingDecision.recordAndSample, attributes);
  }
}
