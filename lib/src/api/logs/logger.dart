// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';

import '../../../api.dart' as api;
import 'log_record.dart';

/// Logger is the interface for emitting logs
abstract class Logger {
  const Logger();

  /// Emit a log record
  void emit({
    required dynamic body,
    Int64? timestamp,
    Int64? observedTimestamp,
    api.Context? context,
    SeverityNumber? severityNumber,
    String? severityText,
    List<api.Attribute>? attributes,
  });

  /// Convenience methods for common severity levels
  void trace(dynamic body,
      {List<api.Attribute>? attributes, api.Context? context}) {
    emit(
      body: body,
      severityNumber: SeverityNumber.trace,
      severityText: 'TRACE',
      attributes: attributes,
      context: context,
    );
  }

  void debug(dynamic body,
      {List<api.Attribute>? attributes, api.Context? context}) {
    emit(
      body: body,
      severityNumber: SeverityNumber.debug,
      severityText: 'DEBUG',
      attributes: attributes,
      context: context,
    );
  }

  void info(dynamic body,
      {List<api.Attribute>? attributes, api.Context? context}) {
    emit(
      body: body,
      severityNumber: SeverityNumber.info,
      severityText: 'INFO',
      attributes: attributes,
      context: context,
    );
  }

  void warn(dynamic body,
      {List<api.Attribute>? attributes, api.Context? context}) {
    emit(
      body: body,
      severityNumber: SeverityNumber.warn,
      severityText: 'WARN',
      attributes: attributes,
      context: context,
    );
  }

  void error(dynamic body,
      {List<api.Attribute>? attributes, api.Context? context}) {
    emit(
      body: body,
      severityNumber: SeverityNumber.error,
      severityText: 'ERROR',
      attributes: attributes,
      context: context,
    );
  }

  void fatal(dynamic body,
      {List<api.Attribute>? attributes, api.Context? context}) {
    emit(
      body: body,
      severityNumber: SeverityNumber.fatal,
      severityText: 'FATAL',
      attributes: attributes,
      context: context,
    );
  }
}
