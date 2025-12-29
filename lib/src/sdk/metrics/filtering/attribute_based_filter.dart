// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../../../../api.dart' as api;
import '../../../../sdk.dart' as sdk;

/// A filter that records measurements based on attribute conditions.
/// Measurements are recorded only if they match the specified attribute key-value pairs.
class AttributeBasedFilter implements sdk.MetricFilter {
  final Map<String, String> _requiredAttributes;

  const AttributeBasedFilter(this._requiredAttributes);

  @override
  String get description =>
      'AttributeBasedFilter{requiredAttributes=${_requiredAttributes.keys.join(", ")}}';

  @override
  sdk.MetricFilterResult shouldRecord(
    String instrumentName,
    num value,
    List<api.Attribute> attributes,
    api.Context? context,
  ) {
    // Check if all required attributes are present with matching values
    for (final entry in _requiredAttributes.entries) {
      final attribute = attributes.firstWhere(
        (attr) => attr.key == entry.key,
        orElse: () => api.Attribute.fromString('', ''),
      );

      if (attribute.key.isEmpty || attribute.value.toString() != entry.value) {
        return sdk.MetricFilterResult(
            sdk.MetricFilterDecision.drop, attributes);
      }
    }

    return sdk.MetricFilterResult(sdk.MetricFilterDecision.record, attributes);
  }
}
