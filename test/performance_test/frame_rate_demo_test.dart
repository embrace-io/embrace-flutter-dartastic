import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/performance_demo/frame_rate_tracker.dart';

import 'performance_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetPerformanceTrackers();
  });

  group('Frame Rate Demo', () {
    testWidgets('displays Start Monitoring button initially', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.text('Start Monitoring'), findsOneWidget);
    });

    testWidgets('button changes to Stop Monitoring when started',
        (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      await tester.tap(find.text('Start Monitoring'));
      await tester.pump();

      expect(find.text('Stop Monitoring'), findsOneWidget);
      expect(find.text('Start Monitoring'), findsNothing);

      // Clean up
      FrameRateTracker.instance.stop();
    });

    testWidgets('displays FPS value', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.textContaining('FPS'), findsWidgets);
    });

    testWidgets('displays average FPS label', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());

      expect(find.textContaining('Avg:'), findsOneWidget);
    });
  });
}
