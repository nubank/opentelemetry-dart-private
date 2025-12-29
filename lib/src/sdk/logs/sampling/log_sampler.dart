// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import '../../../../api.dart' as api;
import '../../../../sdk.dart' as sdk;
import '../../../api/logs/log_record.dart';

/// Represents an entity which determines whether a log record should be sampled
/// and sent for collection.
abstract class LogRecordSampler {
  /// Determines whether a log record should be sampled.
  ///
  /// [context] The current context
  /// [timestamp] The timestamp of the log record
  /// [severityNumber] The severity number
  /// [severityText] The severity text
  /// [body] The log body
  /// [attributes] The log attributes
  sdk.LogSamplingResult shouldSample(
    api.Context? context,
    Int64 timestamp,
    SeverityNumber severityNumber,
    String? severityText,
    dynamic body,
    List<api.Attribute> attributes,
  );

  String get description;
}
