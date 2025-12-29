import '../metric_data.dart';
import 'metric_exporter.dart';

class InMemoryMetricExporter implements MetricExporter {
  final List<MetricData> _metrics = [];
  var _isShutdown = false;

  List<MetricData> get metrics => List.unmodifiable(_metrics);

  void reset() {
    _metrics.clear();
  }

  @override
  void export(List<MetricData> metrics) {
    if (_isShutdown) {
      return;
    }
    _metrics.addAll(metrics);
  }

  @override
  void forceFlush() {
    // In-memory exporter stores immediately
  }

  @override
  void shutdown() {
    _isShutdown = true;
  }
}
