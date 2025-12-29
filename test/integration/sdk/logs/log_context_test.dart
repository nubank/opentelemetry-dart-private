import 'package:test/test.dart';
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;

void main() {
  group('Log Context Integration', () {
    late sdk.InMemoryLogRecordExporter logExporter;
    late sdk.LoggerProviderImpl loggerProvider;
    late sdk.TracerProviderBase tracerProvider;
    late api.Logger logger;
    late api.Tracer tracer;

    setUpAll(() {
      tracerProvider = sdk.TracerProviderBase(processors: []);
      api.registerGlobalTracerProvider(tracerProvider);
    });

    setUp(() {
      logExporter = sdk.InMemoryLogRecordExporter();
      loggerProvider = sdk.LoggerProviderImpl(
        processors: [sdk.SimpleLogRecordProcessor(logExporter)],
      );
      logger = loggerProvider.get('test-logger');
      tracer = tracerProvider.getTracer('test-tracer');
    });

    tearDown(() {
      loggerProvider.shutdown();
      logExporter.reset();
    });

    test('should correlate logs with traces', () {
      final span = tracer.startSpan('test-span');
      final context = api.contextWithSpan(api.Context.current, span);

      logger.emit(body: 'Log within span', context: context);
      span.end();

      expect(logExporter.logs.length, equals(1));
      final log = logExporter.logs.first;
      expect(log.traceId, equals(span.spanContext.traceId));
      expect(log.spanId, equals(span.spanContext.spanId));
    });

    test('should not have trace context without active span', () {
      logger.emit(body: 'Log without span');

      expect(logExporter.logs.length, equals(1));
      final log = logExporter.logs.first;
      expect(log.traceId, isNull);
      expect(log.spanId, isNull);
    });
  });
}
