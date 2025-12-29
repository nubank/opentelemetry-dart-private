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
