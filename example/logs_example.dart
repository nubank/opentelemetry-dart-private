import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;

void main() {
  // Initialize the logger provider with processors and exporters
  final loggerProvider = sdk.LoggerProviderImpl(
    processors: [
      // Simple processor exports immediately
      sdk.SimpleLogRecordProcessor(sdk.ConsoleLogRecordExporter()),
      // Batch processor collects logs and exports in batches
      sdk.BatchLogRecordProcessor(
        sdk.ConsoleLogRecordExporter(),
        maxExportBatchSize: 512,
        scheduledDelayMillis: 5000,
      ),
    ],
    resource: sdk.Resource([
      api.Attribute.fromString('service.name', 'my-service'),
      api.Attribute.fromString('service.version', '1.0.0'),
    ]),
  );

  // Get a logger instance
  final logger = loggerProvider.get(
    'my-logger',
    version: '1.0.0',
  );

  // Emit logs with different severity levels
  logger.trace('This is a trace log');
  logger.debug('This is a debug log');
  logger.info('Application started successfully');
  logger.warn('This is a warning');
  logger.error('An error occurred');
  logger.fatal('Fatal error, application will terminate');

  // Emit logs with custom attributes
  logger.emit(
    body: 'User logged in',
    severityNumber: api.SeverityNumber.info,
    severityText: 'INFO',
    attributes: [
      api.Attribute.fromString('user.id', '12345'),
      api.Attribute.fromString('user.email', 'user@example.com'),
      api.Attribute.fromInt('session.duration', 3600),
    ],
  );

  // Logs can be correlated with traces
  final tracerProvider = sdk.TracerProviderBase(processors: []);
  api.registerGlobalTracerProvider(tracerProvider);
  final tracer = tracerProvider.getTracer('my-tracer');

  final span = tracer.startSpan('process-request');
  final context = api.contextWithSpan(api.Context.current, span);

  // This log will include trace and span IDs
  logger.emit(
    body: 'Processing request',
    context: context,
    severityNumber: api.SeverityNumber.info,
    attributes: [
      api.Attribute.fromString('request.id', 'req-123'),
    ],
  );

  span.end();

  // Clean up
  loggerProvider.forceFlush();
  loggerProvider.shutdown();
}
