// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../../../../api.dart' as api;
import '../../../../sdk.dart' as sdk;

/// A filter that always records metric measurements.
class AlwaysRecordFilter implements sdk.MetricFilter {
  const AlwaysRecordFilter();

  @override
  String get description => 'AlwaysRecordFilter';

  @override
  sdk.MetricFilterResult shouldRecord(
    String instrumentName,
    num value,
    List<api.Attribute> attributes,
    api.Context? context,
  ) {
    return sdk.MetricFilterResult(sdk.MetricFilterDecision.record, attributes);
  }
}
