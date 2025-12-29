// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

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
