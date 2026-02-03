import 'package:flutter/material.dart';
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

  group('Frame Metrics Demo', () {
    testWidgets('displays Reset Metrics button', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Reset Metrics'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Reset Metrics'), findsOneWidget);
    });

    testWidgets('displays Samples label', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Samples'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Samples'), findsOneWidget);
    });

    testWidgets('displays initial sample count as 0', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Samples'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      // The "0" for sample count
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('displays percentile labels', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Build Time'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Build Time'), findsOneWidget);
      // p50 appears multiple times (build, raster, total)
      expect(find.text('p50'), findsWidgets);
    });

    testWidgets('displays Budget Utilization label', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Budget Utilization'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Budget Utilization'), findsOneWidget);
    });

    testWidgets('updates sample count after recording', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      FrameMetricsExporter.instance.recordFrame(
        buildMs: 5.0,
        rasterMs: 8.0,
        totalMs: 13.0,
      );
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Samples'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('Reset Metrics clears sample count', (tester) async {
      FrameMetricsExporter.instance.recordFrame(
        buildMs: 5.0,
        rasterMs: 8.0,
        totalMs: 13.0,
      );

      await tester.pumpWidget(buildPerformanceTestWidget());

      final resetButton = find.text('Reset Metrics');
      await tester.scrollUntilVisible(
        resetButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(resetButton);
      await tester.pumpAndSettle();
      await tester.tap(resetButton);
      await tester.pump();

      // After reset, sampleCount should be 0 again
      expect(FrameMetricsExporter.instance.sampleCount, 0);
    });
  });
}
