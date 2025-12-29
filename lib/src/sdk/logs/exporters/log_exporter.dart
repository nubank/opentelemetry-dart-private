import '../read_only_log_record.dart';

abstract class LogRecordExporter {
  /// Export a batch of log records
  void export(List<ReadOnlyLogRecord> logRecords);

  /// Shut down the exporter
  void shutdown();
}
