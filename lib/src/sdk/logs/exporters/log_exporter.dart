// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../read_only_log_record.dart';

abstract class LogRecordExporter {
  /// Export a batch of log records
  void export(List<ReadOnlyLogRecord> logRecords);

  /// Shut down the exporter
  void shutdown();
}
