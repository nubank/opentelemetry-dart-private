import 'log_exporter.dart';
import '../read_only_log_record.dart';

class ConsoleLogRecordExporter implements LogRecordExporter {
  var _isShutdown = false;

  void _printLogs(List<ReadOnlyLogRecord> logs) {
    for (final log in logs) {
      print({
        'timestamp': log.timestamp,
        'observedTimestamp': log.observedTimestamp,
        'severityNumber': log.severityNumber.value,
        'severityText': log.severityText,
        'body': log.body,
        'traceId': log.traceId?.toString(),
        'spanId': log.spanId?.toString(),
        'attributes': log.attributesMap.keys.map((key) => {
              'key': key,
              'value': log.attributesMap.get(key),
            }),
        'resource': log.resource.attributes.keys.map((key) => {
              'key': key,
              'value': log.resource.attributes.get(key),
            }),
        'instrumentationScope': {
          'name': log.instrumentationScope.name,
          'version': log.instrumentationScope.version,
        },
      });
    }
  }

  @override
  void export(List<ReadOnlyLogRecord> logRecords) {
    if (_isShutdown) {
      return;
    }
    _printLogs(logRecords);
  }

  @override
  void shutdown() {
    _isShutdown = true;
  }
}
