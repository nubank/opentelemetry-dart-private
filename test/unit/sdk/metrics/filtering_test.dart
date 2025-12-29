import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;
import 'package:test/test.dart';

void main() {
  group('MetricFilter', () {
    test('AlwaysRecordFilter should always record', () {
      final filter = sdk.AlwaysRecordFilter();
      final result = filter.shouldRecord(
        'test-counter',
        42,
        [],
        null,
      );

      expect(result.decision, sdk.MetricFilterDecision.record);
      expect(filter.description, 'AlwaysRecordFilter');
    });

    test('NeverRecordFilter should never record', () {
      final filter = sdk.NeverRecordFilter();
      final result = filter.shouldRecord(
        'test-counter',
        42,
        [],
        null,
      );

      expect(result.decision, sdk.MetricFilterDecision.drop);
      expect(filter.description, 'NeverRecordFilter');
    });

    test('AttributeBasedFilter should filter based on attributes', () {
      final filter = sdk.AttributeBasedFilter({
        'environment': 'production',
        'service': 'api',
      });

      // Should drop when attributes don't match
      var result = filter.shouldRecord(
        'test-counter',
        42,
        [api.Attribute.fromString('environment', 'development')],
        null,
      );
      expect(result.decision, sdk.MetricFilterDecision.drop);

      // Should record when all required attributes match
      result = filter.shouldRecord(
        'test-counter',
        42,
        [
          api.Attribute.fromString('environment', 'production'),
          api.Attribute.fromString('service', 'api'),
        ],
        null,
      );
      expect(result.decision, sdk.MetricFilterDecision.record);

      // Should drop when some attributes are missing
      result = filter.shouldRecord(
        'test-counter',
        42,
        [api.Attribute.fromString('environment', 'production')],
        null,
      );
      expect(result.decision, sdk.MetricFilterDecision.drop);

      expect(filter.description, contains('AttributeBasedFilter'));
    });

    test('MeterProvider with filter should respect filtering decisions', () {
      final exporter = sdk.InMemoryMetricExporter();
      final filter = sdk.AttributeBasedFilter({
        'important': 'true',
      });

      final provider = sdk.MeterProviderImpl(
        filter: filter,
      );

      final reader = sdk.ManualMetricReader(() => provider.collectAllMetrics());
      reader.registerExporter(exporter);
      provider.addMetricReader(reader);

      final meter = provider.get('test-meter');
      final counter = meter.createCounter<int>('requests');

      // This should be dropped (no matching attribute)
      counter.add(1, attributes: [
        api.Attribute.fromString('important', 'false'),
      ]);

      // This should be recorded (matching attribute)
      counter.add(10, attributes: [
        api.Attribute.fromString('important', 'true'),
      ]);

      reader.forceFlush();
      final metrics = exporter.metrics;

      expect(metrics.length, 1);
      expect(metrics[0].dataPoints.length, 1);
      expect(metrics[0].dataPoints[0].value, 10);
    });

    test('Counter with NeverRecordFilter should not record any values', () {
      final exporter = sdk.InMemoryMetricExporter();
      final filter = sdk.NeverRecordFilter();

      final provider = sdk.MeterProviderImpl(
        filter: filter,
      );

      final reader = sdk.ManualMetricReader(() => provider.collectAllMetrics());
      reader.registerExporter(exporter);
      provider.addMetricReader(reader);

      final meter = provider.get('test-meter');
      final counter = meter.createCounter<int>('requests');

      counter.add(1);
      counter.add(2);
      counter.add(3);

      reader.forceFlush();
      final metrics = exporter.metrics;

      // No metrics should be recorded
      expect(metrics.length, 0);
    });
  });
}
