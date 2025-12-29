import 'package:fixnum/fixnum.dart';
import '../../../api.dart' as api;

/// Severity Number as defined in OpenTelemetry specification
/// https://opentelemetry.io/docs/reference/specification/logs/data-model/#field-severitynumber
enum SeverityNumber {
  unspecified(0),
  trace(1),
  trace2(2),
  trace3(3),
  trace4(4),
  debug(5),
  debug2(6),
  debug3(7),
  debug4(8),
  info(9),
  info2(10),
  info3(11),
  info4(12),
  warn(13),
  warn2(14),
  warn3(15),
  warn4(16),
  error(17),
  error2(18),
  error3(19),
  error4(20),
  fatal(21),
  fatal2(22),
  fatal3(23),
  fatal4(24);

  const SeverityNumber(this.value);
  final int value;
}

/// Represents a log record as defined in the OpenTelemetry specification
/// https://opentelemetry.io/docs/reference/specification/logs/data-model/
abstract class LogRecord {
  /// Timestamp when the event occurred
  Int64 get timestamp;

  /// Timestamp when the event was observed
  Int64? get observedTimestamp;

  /// Trace ID if the log is associated with a trace
  api.TraceId? get traceId;

  /// Span ID if the log is associated with a span
  api.SpanId? get spanId;

  /// Trace flags
  int? get traceFlags;

  /// Severity number (numerical value)
  SeverityNumber get severityNumber;

  /// Severity text (string representation)
  String? get severityText;

  /// The log message body (can be any type)
  dynamic get body;

  /// Additional attributes
  List<api.Attribute> get attributes;

  /// Dropped attributes count
  int get droppedAttributesCount;
}
