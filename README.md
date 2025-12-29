# OpenTelemetry for Dart

This repository is the Dart implementation of the [OpenTelemetry project](https://opentelemetry.io/). All contributions and designs should follow the [OpenTelemetry specification](https://github.com/open-telemetry/opentelemetry-specification).

## Project Status

| Signal | Status |
| - | - |
| Traces | Beta |
| Metrics | Alpha |
| Logs | Alpha |

## Getting Started

This section will show you how to initialize the OpenTelemetry SDK, capture a span, and propagate context.

### Initialize the OpenTelemetry SDK

```dart
import 'package:opentelemetry/sdk.dart'
    show
        BatchSpanProcessor,
        CollectorExporter,
        ConsoleExporter,
        SimpleSpanProcessor,
        TracerProviderBase;
import 'package:opentelemetry/api.dart'
    show registerGlobalTracerProvider, globalTracerProvider;

void main(List<String> args) {
  final tracerProvider = TracerProviderBase(processors: [
    BatchSpanProcessor(
        CollectorExporter(Uri.parse('https://my-collector.com/v1/traces'))),
    SimpleSpanProcessor(ConsoleExporter())
  ]);

  registerGlobalTracerProvider(tracerProvider);
  final tracer = globalTracerProvider.getTracer('instrumentation-name');
}
```

### Capture a Span

```dart
import 'package:opentelemetry/api.dart' show StatusCode, globalTracerProvider;

void main(List<String> args) {
  final tracer = globalTracerProvider.getTracer('instrumentation-name');

  final span = tracer.startSpan('main');
  try {
    // do some work
    span.addEvent('some work');
  } catch (e, s) {
    span
      ..setStatus(StatusCode.error, e.toString())
      ..recordException(e, stackTrace: s);
    rethrow;
  } finally {
    span.end();
  }
}
```

### Propagate Context

### Intra-process

In order to parent spans, context must be propagated. Propagation can be achieved by manually passing an instance of `Context` or by using Dart [`Zones`](https://dart.dev/libraries/async/zones).

See the [attach detach context example](./example/attach_detach_context)for more information.

### Inter-process

In order to parent spans between processes, context can be serialized and deserialized using a `TextMapPropagator`, `TextMapSetter`, and `TextMapGetter`.

See the [W3C context propagation example](./example/w3c_context_propagation.dart) for more information.

## Logs

OpenTelemetry provides a logging API and SDK for capturing structured logs with correlation to traces and spans.

### Initialize the Logger Provider

```dart
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/api.dart';

void main() {
  // Create a logger provider with processors and exporters
  final loggerProvider = LoggerProviderImpl(
    processors: [
      SimpleLogRecordProcessor(ConsoleLogRecordExporter()),
      BatchLogRecordProcessor(
        InMemoryLogRecordExporter(),
        scheduleDelay: Duration(seconds: 5),
      ),
    ],
  );

  // Get a logger instance
  final logger = loggerProvider.getLogger('my-app');
}
```

### Emit Log Records

```dart
import 'package:opentelemetry/api.dart';

void main() {
  final logger = loggerProvider.getLogger('my-app');

  // Emit logs with different severity levels
  logger.info('Application started');
  logger.warn('Low memory warning');
  logger.error('Failed to process request');

  // Emit logs with attributes
  logger.info(
    'User logged in',
    attributes: [
      Attribute.fromString('user.id', '12345'),
      Attribute.fromString('user.name', 'John Doe'),
    ],
  );

  // Logs are automatically correlated with active spans
  final tracer = globalTracerProvider.getTracer('my-app');
  final span = tracer.startSpan('process-request');
  
  logger.info('Processing request'); // Correlated with span
  
  span.end();
}
```

See the [logs example](./example/logs_example.dart) for more information.

### Log Sampling

Control which log records are processed and exported using samplers:

```dart
import 'package:opentelemetry/sdk.dart';

void main() {
  // Only record logs with severity >= WARN
  final loggerProvider = LoggerProviderImpl(
    processors: [SimpleLogRecordProcessor(ConsoleLogRecordExporter())],
    sampler: SeverityBasedLogSampler(SeverityNumber.warn),
  );

  final logger = loggerProvider.get('my-app');
  
  logger.info('This will be dropped');  // Below threshold
  logger.warn('This will be recorded');  // At threshold
  logger.error('This will be recorded'); // Above threshold
}
```

Available samplers:
- `AlwaysOnLogSampler` - Records all logs (default)
- `AlwaysOffLogSampler` - Drops all logs
- `SeverityBasedLogSampler` - Records logs based on minimum severity level

#### High Resolution Timestamps

A tracer provider can register a web-specific time provider that uses the browser's [performance API](https://developer.mozilla.org/en-US/docs/Web/API/Performance/now) instead of [DateTime](https://api.dart.dev/stable/dart-core/DateTime-class.html) when recording timestamps for a span's start timestamp, end timestamp, and span events.

```dart
import 'package:opentelemetry/web_sdk.dart' as web_sdk;

final tracerProvider =
    web_sdk.WebTracerProvider(timeProvider: web_sdk.WebTimeProvider());
```

Important Note: Span timestamps may be inaccurate if the executing system is suspended for sleep. See [https://github.com/open-telemetry/opentelemetry-js/issues/852](https://github.com/open-telemetry/opentelemetry-js/issues/852) for more information.

## Contributing

In order to generate protobuf definitions, you must have [protoc](https://github.com/protocolbuffers/protobuf/releases) installed and available in your path.

### Publishing New Versions

Only Workiva maintainers can publish new versions of opentelemetry-dart. See [Publishing opentelemetry-dart](https://github.com/Workiva/Observability/blob/master/doc/publishing_opentelemetry_dart.md)
