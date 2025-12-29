import '../metric_data.dart';

/// MetricExporter is responsible for exporting metric data
abstract class MetricExporter {
  /// Export a batch of metrics
  void export(List<MetricData> metrics);

  /// Force flush any buffered metrics
  void forceFlush();

  /// Shutdown the exporter
  void shutdown();
}
