import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'performance_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetPerformanceTrackers();
  });

  group('PerformanceDemoScreen - Structure', () {
    testWidgets('displays screen title', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.text('Performance Demo'), findsOneWidget);
    });

    testWidgets('displays Frame Rate section title', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.text('Frame Rate'), findsOneWidget);
    });

    testWidgets('displays Frame Rate description', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(
        find.textContaining('Monitors real-time frame rate'),
        findsOneWidget,
      );
    });

    testWidgets('displays Jank Detection section title', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.text('Jank Detection'), findsOneWidget);
    });

    testWidgets('displays Jank Detection description', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(
        find.textContaining('Classifies frames as normal'),
        findsOneWidget,
      );
    });

    testWidgets('contains a ListView', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays Jank Simulation section title', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Jank Simulation'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Jank Simulation'), findsOneWidget);
    });

    testWidgets('displays Jank Simulation description', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.textContaining('Intentionally blocks the UI thread'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.textContaining('Intentionally blocks the UI thread'),
        findsOneWidget,
      );
    });

    testWidgets('displays Frame Metrics section title', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Frame Metrics'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Frame Metrics'), findsOneWidget);
    });

    testWidgets('displays Frame Metrics description', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.textContaining('Records build, raster, and total frame times'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.textContaining('Records build, raster, and total frame times'),
        findsOneWidget,
      );
    });
  });
}
