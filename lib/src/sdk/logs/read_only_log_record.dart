import 'package:fixnum/fixnum.dart';
import '../../../api.dart' as api;
import '../../../sdk.dart' as sdk;
import '../../api/logs/log_record.dart';
import '../common/attributes.dart';

/// Read-only interface for log records used by processors and exporters
abstract class ReadOnlyLogRecord implements api.LogRecord {
  /// The instrumentation scope that created this log
  sdk.InstrumentationScope get instrumentationScope;

  /// The resource associated with this log
  sdk.Resource get resource;

  @override
  Int64 get timestamp;

  @override
  Int64? get observedTimestamp;

  @override
  api.TraceId? get traceId;

  @override
  api.SpanId? get spanId;

  @override
  int? get traceFlags;

  @override
  SeverityNumber get severityNumber;

  @override
  String? get severityText;

  @override
  dynamic get body;

  /// Get attributes as SDK Attributes object
  Attributes get attributesMap;

  @override
  int get droppedAttributesCount;

  // Implementation of LogRecord.attributes that converts to List
  @override
  List<api.Attribute> get attributes {
    final attrs = <api.Attribute>[];
    for (final key in attributesMap.keys) {
      final value = attributesMap.get(key);
      if (value != null) {
        if (value is String) {
          attrs.add(api.Attribute.fromString(key, value));
        } else if (value is int) {
          attrs.add(api.Attribute.fromInt(key, value));
        } else if (value is bool) {
          attrs.add(api.Attribute.fromBoolean(key, value));
        } else if (value is double) {
          attrs.add(api.Attribute.fromDouble(key, value));
        }
      }
    }
    return attrs;
  }
}
