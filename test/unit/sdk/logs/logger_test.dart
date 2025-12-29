// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:test/test.dart';
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;

void main() {
  group('Logger', () {
    late sdk.InMemoryLogRecordExporter exporter;
    late sdk.LogRecordProcessor processor;
    late sdk.LoggerProviderImpl loggerProvider;
    late api.Logger logger;

    setUp(() {
      exporter = sdk.InMemoryLogRecordExporter();
      processor = sdk.SimpleLogRecordProcessor(exporter);
      loggerProvider = sdk.LoggerProviderImpl(
        processors: [processor],
        resource: sdk.Resource([
          api.Attribute.fromString('service.name', 'test-service'),
        ]),
      );
      logger = loggerProvider.get('test-logger', version: '1.0.0');
    });

    tearDown(() {
      loggerProvider.shutdown();
      exporter.reset();
    });

    test('should emit a log record', () {
      logger.emit(body: 'Test log message');

      expect(exporter.logs.length, equals(1));
      final log = exporter.logs.first;
      expect(log.body, equals('Test log message'));
      expect(log.severityNumber, equals(api.SeverityNumber.unspecified));
    });

    test('should emit log with severity', () {
      logger.emit(
        body: 'Error occurred',
        severityNumber: api.SeverityNumber.error,
        severityText: 'ERROR',
      );

      expect(exporter.logs.length, equals(1));
      final log = exporter.logs.first;
      expect(log.body, equals('Error occurred'));
      expect(log.severityNumber, equals(api.SeverityNumber.error));
      expect(log.severityText, equals('ERROR'));
    });

    test('should emit log with attributes', () {
      logger.emit(
        body: 'Log with attributes',
        attributes: [
          api.Attribute.fromString('key1', 'value1'),
          api.Attribute.fromInt('key2', 42),
        ],
      );

      expect(exporter.logs.length, equals(1));
      final log = exporter.logs.first;
      expect(log.attributesMap.get('key1'), equals('value1'));
      expect(log.attributesMap.get('key2'), equals(42));
    });

    test('should use convenience methods', () {
      logger.info('Info message');
      logger.warn('Warning message');
      logger.error('Error message');

      expect(exporter.logs.length, equals(3));
      expect(exporter.logs[0].severityText, equals('INFO'));
      expect(exporter.logs[1].severityText, equals('WARN'));
      expect(exporter.logs[2].severityText, equals('ERROR'));
    });

    test('should include resource information', () {
      logger.emit(body: 'Test');

      final log = exporter.logs.first;
      expect(
          log.resource.attributes.get('service.name'), equals('test-service'));
    });

    test('should include instrumentation scope', () {
      logger.emit(body: 'Test');

      final log = exporter.logs.first;
      expect(log.instrumentationScope.name, equals('test-logger'));
      expect(log.instrumentationScope.version, equals('1.0.0'));
    });
  });

  group('BatchLogRecordProcessor', () {
    late sdk.InMemoryLogRecordExporter exporter;
    late sdk.BatchLogRecordProcessor processor;
    late sdk.LoggerProviderImpl loggerProvider;
    late api.Logger logger;

    setUp(() {
      exporter = sdk.InMemoryLogRecordExporter();
      processor = sdk.BatchLogRecordProcessor(
        exporter,
        maxExportBatchSize: 5,
        scheduledDelayMillis: 100,
      );
      loggerProvider = sdk.LoggerProviderImpl(
        processors: [processor],
      );
      logger = loggerProvider.get('test-logger');
    });

    tearDown(() {
      loggerProvider.shutdown();
      exporter.reset();
    });

    test('should batch log records', () async {
      for (var i = 0; i < 10; i++) {
        logger.emit(body: 'Log $i');
      }

      // Wait for batch export
      await Future.delayed(Duration(milliseconds: 200));

      expect(exporter.logs.length, greaterThan(0));
    });

    test('should export on force flush', () {
      for (var i = 0; i < 3; i++) {
        logger.emit(body: 'Log $i');
      }

      processor.forceFlush();
      expect(exporter.logs.length, equals(3));
    });
  });

  group('ConsoleLogRecordExporter', () {
    test('should not throw on export', () {
      final exporter = sdk.ConsoleLogRecordExporter();
      final processor = sdk.SimpleLogRecordProcessor(exporter);
      final loggerProvider = sdk.LoggerProviderImpl(processors: [processor]);
      final logger = loggerProvider.get('test-logger');

      expect(() => logger.emit(body: 'Test log'), returnsNormally);

      loggerProvider.shutdown();
    });
  });
}
