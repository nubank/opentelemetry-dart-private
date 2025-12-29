import 'log_exporter.dart';
import '../read_only_log_record.dart';

class InMemoryLogRecordExporter implements LogRecordExporter {
  final List<ReadOnlyLogRecord> _logs = [];
  var _isShutdown = false;

  List<ReadOnlyLogRecord> get logs => List.unmodifiable(_logs);

  void reset() {
    _logs.clear();
  }

  @override
  void export(List<ReadOnlyLogRecord> logRecords) {
    if (_isShutdown) {
      return;
    }
    _logs.addAll(logRecords);
  }

  @override
  void shutdown() {
    _isShutdown = true;
  }
}
