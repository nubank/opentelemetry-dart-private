import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:opentelemetry/src/api/logs/log_record.dart';
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  group('LogRecordSampler', () {
    test('AlwaysOnLogSampler should always sample', () {
      final sampler = sdk.AlwaysOnLogSampler();
      final result = sampler.shouldSample(
        null,
        Int64(DateTime.now().millisecondsSinceEpoch),
        SeverityNumber.info,
        'Info',
        'Test log',
        [],
      );

      expect(result.decision, sdk.LogSamplingDecision.recordAndSample);
      expect(sampler.description, 'AlwaysOnLogSampler');
    });

    test('AlwaysOffLogSampler should never sample', () {
      final sampler = sdk.AlwaysOffLogSampler();
      final result = sampler.shouldSample(
        null,
        Int64(DateTime.now().millisecondsSinceEpoch),
        SeverityNumber.info,
        'Info',
        'Test log',
        [],
      );

      expect(result.decision, sdk.LogSamplingDecision.drop);
      expect(sampler.description, 'AlwaysOffLogSampler');
    });

    test('SeverityBasedLogSampler should sample based on severity', () {
      final sampler = sdk.SeverityBasedLogSampler(SeverityNumber.warn);

      // Should drop logs below warning level
      var result = sampler.shouldSample(
        null,
        Int64(DateTime.now().millisecondsSinceEpoch),
        SeverityNumber.info,
        'Info',
        'Test log',
        [],
      );
      expect(result.decision, sdk.LogSamplingDecision.drop);

      // Should sample warning level
      result = sampler.shouldSample(
        null,
        Int64(DateTime.now().millisecondsSinceEpoch),
        SeverityNumber.warn,
        'Warn',
        'Test log',
        [],
      );
      expect(result.decision, sdk.LogSamplingDecision.recordAndSample);

      // Should sample error level (above warning)
      result = sampler.shouldSample(
        null,
        Int64(DateTime.now().millisecondsSinceEpoch),
        SeverityNumber.error,
        'Error',
        'Test log',
        [],
      );
      expect(result.decision, sdk.LogSamplingDecision.recordAndSample);

      expect(sampler.description, contains('SeverityBasedLogSampler'));
      expect(sampler.description, contains('warn'));
    });

    test('LoggerProvider with sampler should respect sampling decisions', () {
      final exporter = sdk.InMemoryLogRecordExporter();
      final processor = sdk.SimpleLogRecordProcessor(exporter);
      final sampler = sdk.SeverityBasedLogSampler(SeverityNumber.warn);

      final provider = sdk.LoggerProviderImpl(
        processors: [processor],
        sampler: sampler,
      );

      final logger = provider.get('test-logger');

      // Info log should be dropped
      logger.info('Info message');
      expect(exporter.logs.length, 0);

      // Warning log should be recorded
      logger.warn('Warning message');
      expect(exporter.logs.length, 1);
      expect(exporter.logs[0].body, 'Warning message');

      // Error log should be recorded
      logger.error('Error message');
      expect(exporter.logs.length, 2);
      expect(exporter.logs[1].body, 'Error message');
    });
  });
}
