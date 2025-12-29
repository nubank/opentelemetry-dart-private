import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import '../../../api.dart' as api;
import '../../../sdk.dart' as sdk;
import '../../api/logs/log_record.dart';
import '../common/attributes.dart';
import '../common/limits.dart';
import 'read_only_log_record.dart';

@protected
class LogRecordImpl implements ReadOnlyLogRecord {
  @override
  final Int64 timestamp;

  @override
  final Int64? observedTimestamp;

  @override
  final api.TraceId? traceId;

  @override
  final api.SpanId? spanId;

  @override
  final int? traceFlags;

  @override
  final SeverityNumber severityNumber;

  @override
  final String? severityText;

  @override
  final dynamic body;

  @override
  final Attributes attributesMap;

  @override
  int droppedAttributesCount;

  @override
  final sdk.InstrumentationScope instrumentationScope;

  @override
  final sdk.Resource resource;

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

  LogRecordImpl({
    required this.timestamp,
    this.observedTimestamp,
    this.traceId,
    this.spanId,
    this.traceFlags,
    required this.severityNumber,
    this.severityText,
    required this.body,
    required List<api.Attribute> inputAttributes,
    required this.instrumentationScope,
    required this.resource,
    required sdk.SpanLimits limits,
  })  : attributesMap = Attributes.empty(),
        droppedAttributesCount = 0 {
    // Apply limits to attributes
    var dropped = 0;
    for (final attr in inputAttributes) {
      if (limits.maxNumAttributes > 0 &&
          attributesMap.length >= limits.maxNumAttributes) {
        dropped++;
      } else {
        attributesMap.add(applyAttributeLimits(attr, limits));
      }
    }
    droppedAttributesCount = dropped;
  }
}
