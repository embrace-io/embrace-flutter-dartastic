import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/performance_demo/frame_metrics_exporter.dart';

import 'performance_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetPerformanceTrackers();
  });

  group('FrameMetricsExporter - Initial State', () {
    test('sampleCount is zero initially', () {
      expect(FrameMetricsExporter.instance.sampleCount, 0);
    });

    test('budgetUtilization is zero initially', () {
      expect(FrameMetricsExporter.instance.budgetUtilization, 0.0);
    });

    test('all percentiles are zero initially', () {
      final exporter = FrameMetricsExporter.instance;
      expect(exporter.buildP50, 0.0);
      expect(exporter.buildP90, 0.0);
      expect(exporter.buildP95, 0.0);
      expect(exporter.buildP99, 0.0);
      expect(exporter.rasterP50, 0.0);
      expect(exporter.totalP50, 0.0);
    });
  });

  group('FrameMetricsExporter - Recording', () {
    test('recordFrame increments sample count', () {
      final exporter = FrameMetricsExporter.instance;
      exporter.recordFrame(buildMs: 5.0, rasterMs: 8.0, totalMs: 13.0);
      expect(exporter.sampleCount, 1);
    });

    test('multiple recordings accumulate', () {
      final exporter = FrameMetricsExporter.instance;
      exporter.recordFrame(buildMs: 5.0, rasterMs: 8.0, totalMs: 13.0);
      exporter.recordFrame(buildMs: 6.0, rasterMs: 7.0, totalMs: 13.0);
      exporter.recordFrame(buildMs: 4.0, rasterMs: 9.0, totalMs: 13.0);
      expect(exporter.sampleCount, 3);
    });

    test('recordFrame notifies listeners', () {
      final exporter = FrameMetricsExporter.instance;
      var notifyCount = 0;
      void listener() => notifyCount++;
      exporter.addListener(listener);

      exporter.recordFrame(buildMs: 5.0, rasterMs: 8.0, totalMs: 13.0);
      expect(notifyCount, 1);

      exporter.removeListener(listener);
    });
  });

  group('FrameMetricsExporter - Percentile Calculation', () {
    test('single sample returns that value for all percentiles', () {
      final exporter = FrameMetricsExporter.instance;
      exporter.recordFrame(buildMs: 10.0, rasterMs: 5.0, totalMs: 15.0);
      expect(exporter.buildP50, 10.0);
      expect(exporter.buildP99, 10.0);
      expect(exporter.rasterP50, 5.0);
      expect(exporter.totalP50, 15.0);
    });

    test('p50 returns median for sorted data', () {
      final exporter = FrameMetricsExporter.instance;
      // Insert values in random order to test sorting
      for (final v in [2.0, 8.0, 4.0, 6.0, 10.0]) {
        exporter.recordFrame(buildMs: v, rasterMs: v, totalMs: v);
      }
      // Sorted: [2, 4, 6, 8, 10] → p50 index = round(0.5 * 4) = 2 → value 6
      expect(exporter.buildP50, 6.0);
    });

    test('p90 returns high percentile value', () {
      final exporter = FrameMetricsExporter.instance;
      for (var i = 1; i <= 100; i++) {
        exporter.recordFrame(
          buildMs: i.toDouble(),
          rasterMs: i.toDouble(),
          totalMs: i.toDouble(),
        );
      }
      // p90 index = round(0.90 * 99) = round(89.1) = 89 → value 90
      expect(exporter.buildP90, 90.0);
    });
  });

  group('FrameMetricsExporter - Budget Utilization', () {
    test('budget utilization reflects average total time', () {
      final exporter = FrameMetricsExporter.instance;
      // 16ms budget, 8ms avg total → 50%
      exporter.recordFrame(buildMs: 4.0, rasterMs: 4.0, totalMs: 8.0);
      expect(exporter.budgetUtilization, 50.0);
    });

    test('budget utilization over 100% when exceeding budget', () {
      final exporter = FrameMetricsExporter.instance;
      exporter.recordFrame(buildMs: 16.0, rasterMs: 16.0, totalMs: 32.0);
      expect(exporter.budgetUtilization, 200.0);
    });
  });

  group('FrameMetricsExporter - Reset', () {
    test('resetDisplay clears local data', () {
      final exporter = FrameMetricsExporter.instance;
      exporter.recordFrame(buildMs: 5.0, rasterMs: 8.0, totalMs: 13.0);
      exporter.recordFrame(buildMs: 6.0, rasterMs: 7.0, totalMs: 13.0);

      exporter.resetDisplay();

      expect(exporter.sampleCount, 0);
      expect(exporter.buildP50, 0.0);
      expect(exporter.budgetUtilization, 0.0);
    });

    test('resetDisplay notifies listeners', () {
      final exporter = FrameMetricsExporter.instance;
      exporter.recordFrame(buildMs: 5.0, rasterMs: 8.0, totalMs: 13.0);

      var notifyCount = 0;
      void listener() => notifyCount++;
      exporter.addListener(listener);

      exporter.resetDisplay();
      expect(notifyCount, 1);

      exporter.removeListener(listener);
    });
  });
}
