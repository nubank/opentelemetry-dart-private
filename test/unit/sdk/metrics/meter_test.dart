import 'package:test/test.dart';
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;

void main() {
  group('Counter', () {
    late sdk.InMemoryMetricExporter exporter;
    late sdk.ManualMetricReader reader;
    late sdk.MeterProviderImpl meterProvider;
    late api.Meter meter;

    setUp(() {
      exporter = sdk.InMemoryMetricExporter();
      meterProvider = sdk.MeterProviderImpl(
        resource: sdk.Resource([
          api.Attribute.fromString('service.name', 'test-service'),
        ]),
      );
      reader = sdk.ManualMetricReader(() => meterProvider.collectAllMetrics());
      reader.registerExporter(exporter);
      meterProvider.addMetricReader(reader);
      meter = meterProvider.get('test-meter', version: '1.0.0');
    });

    tearDown(() {
      meterProvider.shutdown();
      exporter.reset();
    });

    test('should record counter values', () {
      final counter = meter.createCounter<int>('test-counter');
      counter.add(5);
      counter.add(10);

      reader.forceFlush();

      expect(exporter.metrics.length, equals(1));
      final metric = exporter.metrics.first;
      expect(metric.descriptor.name, equals('test-counter'));
      expect(metric.descriptor.type, equals(sdk.InstrumentType.counter));
      expect(metric.dataPoints.length, equals(1));
      expect(metric.dataPoints.first.value, equals(15));
    });

    test('should record counter with attributes', () {
      final counter = meter.createCounter<int>('requests-counter');
      counter.add(1, attributes: [
        api.Attribute.fromString('method', 'GET'),
        api.Attribute.fromString('path', '/api'),
      ]);
      counter.add(2, attributes: [
        api.Attribute.fromString('method', 'POST'),
        api.Attribute.fromString('path', '/api'),
      ]);

      reader.forceFlush();

      final metric = exporter.metrics.first;
      expect(metric.dataPoints.length, equals(2));
    });

    test('should reject negative counter values', () {
      final counter = meter.createCounter<int>('test-counter');
      counter.add(-5);

      reader.forceFlush();

      expect(exporter.metrics.length, equals(0));
    });
  });

  group('UpDownCounter', () {
    late sdk.InMemoryMetricExporter exporter;
    late sdk.ManualMetricReader reader;
    late sdk.MeterProviderImpl meterProvider;
    late api.Meter meter;

    setUp(() {
      exporter = sdk.InMemoryMetricExporter();
      meterProvider = sdk.MeterProviderImpl();
      reader = sdk.ManualMetricReader(() => meterProvider.collectAllMetrics());
      reader.registerExporter(exporter);
      meterProvider.addMetricReader(reader);
      meter = meterProvider.get('test-meter');
    });

    tearDown(() {
      meterProvider.shutdown();
      exporter.reset();
    });

    test('should record positive and negative values', () {
      final upDownCounter = meter.createUpDownCounter<int>('queue-size');
      upDownCounter.add(10);
      upDownCounter.add(-3);
      upDownCounter.add(5);

      reader.forceFlush();

      expect(exporter.metrics.length, equals(1));
      final metric = exporter.metrics.first;
      expect(metric.descriptor.type, equals(sdk.InstrumentType.upDownCounter));
      expect(metric.dataPoints.first.value, equals(12));
    });
  });

  group('Histogram', () {
    late sdk.InMemoryMetricExporter exporter;
    late sdk.ManualMetricReader reader;
    late sdk.MeterProviderImpl meterProvider;
    late api.Meter meter;

    setUp(() {
      exporter = sdk.InMemoryMetricExporter();
      meterProvider = sdk.MeterProviderImpl();
      reader = sdk.ManualMetricReader(() => meterProvider.collectAllMetrics());
      reader.registerExporter(exporter);
      meterProvider.addMetricReader(reader);
      meter = meterProvider.get('test-meter');
    });

    tearDown(() {
      meterProvider.shutdown();
      exporter.reset();
    });

    test('should record histogram values', () {
      final histogram = meter.createHistogram<double>('response-time');
      histogram.record(23.5);
      histogram.record(45.0);
      histogram.record(12.3);
      histogram.record(78.9);

      reader.forceFlush();

      expect(exporter.metrics.length, equals(1));
      final metric = exporter.metrics.first;
      expect(metric.descriptor.type, equals(sdk.InstrumentType.histogram));
      expect(metric.histogramDataPoints.length, equals(1));

      final histogramData = metric.histogramDataPoints.first;
      expect(histogramData.count, equals(4));
      expect(histogramData.sum, equals(159.7));
      expect(histogramData.min, equals(12.3));
      expect(histogramData.max, equals(78.9));
      expect(histogramData.buckets.isNotEmpty, isTrue);
    });

    test('should create buckets correctly', () {
      final histogram = meter.createHistogram<int>('request-size');
      for (var i = 0; i < 100; i++) {
        histogram.record(i);
      }

      reader.forceFlush();

      final metric = exporter.metrics.first;
      final histogramData = metric.histogramDataPoints.first;
      expect(histogramData.buckets.isNotEmpty, isTrue);
    });
  });

  group('ObservableGauge', () {
    late sdk.InMemoryMetricExporter exporter;
    late sdk.ManualMetricReader reader;
    late sdk.MeterProviderImpl meterProvider;
    late api.Meter meter;

    setUp(() {
      exporter = sdk.InMemoryMetricExporter();
      meterProvider = sdk.MeterProviderImpl();
      reader = sdk.ManualMetricReader(() => meterProvider.collectAllMetrics());
      reader.registerExporter(exporter);
      meterProvider.addMetricReader(reader);
      meter = meterProvider.get('test-meter');
    });

    tearDown(() {
      meterProvider.shutdown();
      exporter.reset();
    });

    test('should observe gauge values via callback', () {
      var cpuUsage = 45.5;

      meter.createObservableGauge<double>(
        'cpu-usage',
        (result) {
          result.observe(cpuUsage);
        },
        description: 'CPU usage percentage',
        unit: '%',
      );

      reader.forceFlush();

      expect(exporter.metrics.length, equals(1));
      final metric = exporter.metrics.first;
      expect(
          metric.descriptor.type, equals(sdk.InstrumentType.observableGauge));
      expect(metric.dataPoints.first.value, equals(45.5));
    });

    test('should observe multiple values with attributes', () {
      meter.createObservableGauge<double>(
        'memory-usage',
        (result) {
          result.observe(1024.0, attributes: [
            api.Attribute.fromString('type', 'heap'),
          ]);
          result.observe(512.0, attributes: [
            api.Attribute.fromString('type', 'stack'),
          ]);
        },
      );

      reader.forceFlush();

      final metric = exporter.metrics.first;
      expect(metric.dataPoints.length, equals(2));
    });
  });

  group('PeriodicMetricReader', () {
    late sdk.InMemoryMetricExporter exporter;
    late sdk.PeriodicMetricReader reader;
    late sdk.MeterProviderImpl meterProvider;
    late api.Meter meter;

    setUp(() {
      exporter = sdk.InMemoryMetricExporter();
      meterProvider = sdk.MeterProviderImpl();
      reader = sdk.PeriodicMetricReader(
        () => meterProvider.collectAllMetrics(),
        exportIntervalMillis: 100,
      );
      reader.registerExporter(exporter);
      meterProvider.addMetricReader(reader);
      meter = meterProvider.get('test-meter');
    });

    tearDown(() {
      meterProvider.shutdown();
      exporter.reset();
    });

    test('should export metrics periodically', () async {
      final counter = meter.createCounter<int>('periodic-counter');
      counter.add(10);

      // Wait for periodic export
      await Future.delayed(Duration(milliseconds: 150));

      expect(exporter.metrics.length, greaterThan(0));
    });
  });

  group('ConsoleMetricExporter', () {
    test('should not throw on export', () {
      final exporter = sdk.ConsoleMetricExporter();
      final meterProvider = sdk.MeterProviderImpl();
      final reader =
          sdk.ManualMetricReader(() => meterProvider.collectAllMetrics());
      reader.registerExporter(exporter);
      meterProvider.addMetricReader(reader);
      final meter = meterProvider.get('test-meter');

      final counter = meter.createCounter<int>('test-counter');
      counter.add(42);

      expect(() => reader.forceFlush(), returnsNormally);

      meterProvider.shutdown();
    });
  });
}
