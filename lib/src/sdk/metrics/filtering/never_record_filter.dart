// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../../../../api.dart' as api;
import '../../../../sdk.dart' as sdk;

/// A filter that never records metric measurements.
class NeverRecordFilter implements sdk.MetricFilter {
  const NeverRecordFilter();

  @override
  String get description => 'NeverRecordFilter';

  @override
  sdk.MetricFilterResult shouldRecord(
    String instrumentName,
    num value,
    List<api.Attribute> attributes,
    api.Context? context,
  ) {
    return sdk.MetricFilterResult(sdk.MetricFilterDecision.drop, attributes);
  }
}
