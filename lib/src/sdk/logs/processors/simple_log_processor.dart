// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../../../../api.dart' as api;
import '../exporters/log_exporter.dart';
import 'log_processor.dart';
import '../read_only_log_record.dart';

class SimpleLogRecordProcessor implements LogRecordProcessor {
  final LogRecordExporter _exporter;
  bool _isShutdown = false;

  SimpleLogRecordProcessor(this._exporter);

  @override
  void onEmit(ReadOnlyLogRecord logRecord, api.Context? context) {
    if (_isShutdown) {
      return;
    }
    _exporter.export([logRecord]);
  }

  @override
  void forceFlush() {
    // Simple processor exports immediately, nothing to flush
  }

  @override
  void shutdown() {
    _isShutdown = true;
    _exporter.shutdown();
  }
}
