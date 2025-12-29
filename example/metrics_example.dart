// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/sdk.dart' as sdk;

void main() async {
  // Initialize the meter provider with readers and exporters
  final meterProvider = sdk.MeterProviderImpl(
    resource: sdk.Resource([
      api.Attribute.fromString('service.name', 'my-service'),
      api.Attribute.fromString('service.version', '1.0.0'),
    ]),
  );

  // Create a periodic reader that exports metrics every 60 seconds
  final periodicReader = sdk.PeriodicMetricReader(
    () => meterProvider.collectAllMetrics(),
    exportIntervalMillis: 60000,
  );
  periodicReader.registerExporter(sdk.ConsoleMetricExporter());
  meterProvider.addMetricReader(periodicReader);

  // Get a meter instance
  final meter = meterProvider.get('my-meter', version: '1.0.0');

  // Create a counter for tracking requests
  final requestCounter = meter.createCounter<int>(
    'http.server.requests',
    description: 'Total number of HTTP requests',
    unit: 'requests',
  );

  // Record some requests
  requestCounter.add(1, attributes: [
    api.Attribute.fromString('http.method', 'GET'),
    api.Attribute.fromString('http.route', '/api/users'),
    api.Attribute.fromInt('http.status_code', 200),
  ]);

  requestCounter.add(1, attributes: [
    api.Attribute.fromString('http.method', 'POST'),
    api.Attribute.fromString('http.route', '/api/users'),
    api.Attribute.fromInt('http.status_code', 201),
  ]);

  // Create an UpDownCounter for tracking active connections
  final activeConnections = meter.createUpDownCounter<int>(
    'http.server.active_connections',
    description: 'Number of active HTTP connections',
    unit: 'connections',
  );

  activeConnections.add(5); // 5 connections opened
  activeConnections.add(-2); // 2 connections closed

  // Create a histogram for tracking request duration
  final requestDuration = meter.createHistogram<double>(
    'http.server.request.duration',
    description: 'HTTP request duration',
    unit: 'ms',
  );

  requestDuration.record(23.5, attributes: [
    api.Attribute.fromString('http.method', 'GET'),
  ]);
  requestDuration.record(45.2, attributes: [
    api.Attribute.fromString('http.method', 'POST'),
  ]);
  requestDuration.record(12.8, attributes: [
    api.Attribute.fromString('http.method', 'GET'),
  ]);

  // Create an observable gauge for system metrics
  var cpuUsage = 45.5;
  meter.createObservableGauge<double>(
    'system.cpu.usage',
    (result) {
      // This callback is invoked when metrics are collected
      result.observe(cpuUsage, attributes: [
        api.Attribute.fromString('cpu', 'cpu0'),
      ]);
    },
    description: 'CPU usage percentage',
    unit: '%',
  );

  // Manually trigger metric collection and export
  meterProvider.forceFlush();

  // Wait a bit to see periodic export
  await Future.delayed(Duration(seconds: 2));

  // Clean up
  meterProvider.shutdown();
}
