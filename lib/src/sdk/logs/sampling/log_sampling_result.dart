import '../../../../api.dart' as api;

/// Decision for log record sampling
enum LogSamplingDecision {
  /// Drop the log record - it will not be recorded or exported
  drop,

  /// Record the log record but don't necessarily export it
  recordOnly,

  /// Record and export the log record
  recordAndSample,
}

/// Result of a log sampling decision
class LogSamplingResult {
  final LogSamplingDecision decision;
  final List<api.Attribute> attributes;

  LogSamplingResult(this.decision, this.attributes);
}
