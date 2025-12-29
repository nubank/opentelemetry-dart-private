// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

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
