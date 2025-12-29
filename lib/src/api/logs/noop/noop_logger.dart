import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart' as api;

import '../log_record.dart';
import '../logger.dart';

class NoopLogger extends Logger {
  const NoopLogger();

  @override
  void emit({
    required dynamic body,
    Int64? timestamp,
    Int64? observedTimestamp,
    api.Context? context,
    SeverityNumber? severityNumber,
    String? severityText,
    List<api.Attribute>? attributes,
  }) {}
}
