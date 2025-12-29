import '../../../api.dart' as api;
import '../../../sdk.dart' as sdk;
import '../common/instrumentation_scope.dart';
import 'processors/log_processor.dart';
import 'logger.dart';

class LoggerProviderImpl implements api.LoggerProvider {
  final List<LogRecordProcessor> _processors;
  final sdk.Resource _resource;
  final sdk.TimeProvider _timeProvider;
  final sdk.SpanLimits _limits;
  final sdk.LogRecordSampler _sampler;

  LoggerProviderImpl({
    required List<LogRecordProcessor> processors,
    sdk.Resource? resource,
    sdk.TimeProvider? timeProvider,
    sdk.SpanLimits? limits,
    sdk.LogRecordSampler? sampler,
  })  : _processors = processors,
        _resource = resource ?? sdk.Resource([]),
        _timeProvider = timeProvider ?? sdk.DateTimeTimeProvider(),
        _limits = limits ?? sdk.SpanLimits(),
        _sampler = sampler ?? const sdk.AlwaysOnLogSampler();

  @override
  api.Logger get(
    String name, {
    String version = '',
    String schemaUrl = '',
    List<api.Attribute> attributes = const [],
  }) {
    final instrumentationScope = InstrumentationScope(
      name,
      version,
      schemaUrl,
      attributes,
    );

    return LoggerImpl(
      _processors,
      _resource,
      instrumentationScope,
      _timeProvider,
      _limits,
      _sampler,
    );
  }

  void shutdown() {
    for (final processor in _processors) {
      processor.shutdown();
    }
  }

  void forceFlush() {
    for (final processor in _processors) {
      processor.forceFlush();
    }
  }
}
