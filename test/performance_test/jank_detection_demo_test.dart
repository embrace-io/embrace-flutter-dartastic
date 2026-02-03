import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/performance_demo/jank_detector.dart';

import 'performance_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetPerformanceTrackers();
  });

  group('Jank Detection Demo', () {
    testWidgets('displays Jank Frames label', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.text('Jank Frames'), findsOneWidget);
    });

    testWidgets('displays initial jank count as zero', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      // The row shows "Jank Frames" and "0"
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('displays Jank % label', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.text('Jank %'), findsOneWidget);
    });

    testWidgets('displays Severe Jank label', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.text('Severe Jank'), findsOneWidget);
    });

    testWidgets('displays percentage as 0.0%', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.text('0.0%'), findsOneWidget);
    });

    testWidgets('updates when jank is detected', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      JankDetector.instance.evaluateFrameDuration(25.0);
      await tester.pump();

      expect(find.text('1'), findsWidgets);

      // Pump through the flash timer to avoid pending timer error.
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
