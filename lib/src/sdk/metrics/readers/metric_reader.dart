import '../metric_data.dart';
import '../exporters/metric_exporter.dart';

/// MetricReader defines how metrics are read and exported
abstract class MetricReader {
  /// Collect metrics from all registered instruments
  List<MetricData> collect();

  /// Force flush any buffered metrics
  void forceFlush();

  /// Shutdown the reader
  void shutdown();

  /// Register an exporter with this reader
  void registerExporter(MetricExporter exporter);
}
