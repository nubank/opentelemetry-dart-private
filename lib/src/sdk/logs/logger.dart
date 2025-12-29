import 'package:fixnum/fixnum.dart';
import '../../../api.dart' as api;
import '../../../sdk.dart' as sdk;
import '../../api/logs/log_record.dart';
import 'processors/log_processor.dart';
import 'log_record.dart' as log_record_impl;

class LoggerImpl extends api.Logger {
  final List<LogRecordProcessor> _processors;
  final sdk.Resource _resource;
  final sdk.InstrumentationScope _instrumentationScope;
  final sdk.TimeProvider _timeProvider;
  final sdk.SpanLimits _limits;
  final sdk.LogRecordSampler _sampler;

  LoggerImpl(
    this._processors,
    this._resource,
    this._instrumentationScope,
    this._timeProvider,
    this._limits,
    this._sampler,
  );

  @override
  void emit({
    required dynamic body,
    Int64? timestamp,
    Int64? observedTimestamp,
    api.Context? context,
    SeverityNumber? severityNumber,
    String? severityText,
    List<api.Attribute>? attributes,
  }) {
    final effectiveContext = context ?? api.Context.current;
    final effectiveSeverity = severityNumber ?? SeverityNumber.unspecified;
    final effectiveTimestamp = timestamp ?? _timeProvider.now;
    final effectiveAttributes = attributes ?? [];

    // Apply sampling decision
    final samplingResult = _sampler.shouldSample(
      effectiveContext,
      effectiveTimestamp,
      effectiveSeverity,
      severityText,
      body,
      effectiveAttributes,
    );

    // Drop the log if sampling decision says so
    if (samplingResult.decision == sdk.LogSamplingDecision.drop) {
      return;
    }

    final spanContext = api.spanContextFromContext(effectiveContext);

    final logRecord = log_record_impl.LogRecordImpl(
      timestamp: effectiveTimestamp,
      observedTimestamp: observedTimestamp ?? _timeProvider.now,
      traceId: spanContext.traceId.isValid ? spanContext.traceId : null,
      spanId: spanContext.spanId.isValid ? spanContext.spanId : null,
      traceFlags: spanContext.traceFlags,
      severityNumber: effectiveSeverity,
      severityText: severityText,
      body: body,
      inputAttributes: samplingResult.attributes,
      instrumentationScope: _instrumentationScope,
      resource: _resource,
      limits: _limits,
    );

    // Only process if decision is recordAndSample
    if (samplingResult.decision == sdk.LogSamplingDecision.recordAndSample) {
      for (final processor in _processors) {
        processor.onEmit(logRecord, effectiveContext);
      }
    }
  }
}
