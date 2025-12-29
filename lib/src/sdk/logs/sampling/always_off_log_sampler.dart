import 'package:fixnum/fixnum.dart';
import '../../../../api.dart' as api;
import '../../../../sdk.dart' as sdk;
import '../../../api/logs/log_record.dart';

/// A sampler that never samples log records.
class AlwaysOffLogSampler implements sdk.LogRecordSampler {
  const AlwaysOffLogSampler();

  @override
  String get description => 'AlwaysOffLogSampler';

  @override
  sdk.LogSamplingResult shouldSample(
    api.Context? context,
    Int64 timestamp,
    SeverityNumber severityNumber,
    String? severityText,
    dynamic body,
    List<api.Attribute> attributes,
  ) {
    return sdk.LogSamplingResult(sdk.LogSamplingDecision.drop, attributes);
  }
}
