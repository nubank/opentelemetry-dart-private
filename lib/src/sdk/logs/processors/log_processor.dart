import '../../../../api.dart' as api;
import '../read_only_log_record.dart';

abstract class LogRecordProcessor {
  /// Called when a log record is emitted
  void onEmit(ReadOnlyLogRecord logRecord, api.Context? context);

  /// Forces flush of any buffered log records
  void forceFlush();

  /// Shuts down the processor
  void shutdown();
}
