import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/lifecycle_demo/foreground_tracker.dart';

import 'lifecycle_test_helpers.dart';

const _tick = Duration(milliseconds: 1);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('ForegroundTrackingDemo - UI', () {
    testWidgets('displays section title', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Foreground / Background'), findsOneWidget);
    });

    testWidgets('displays section description', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(
        find.textContaining('Tracks foreground session spans'),
        findsOneWidget,
      );
    });

    testWidgets('shows Foreground indicator initially', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Foreground'), findsOneWidget);
    });

    testWidgets('shows cumulative foreground label', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Cumulative Foreground'), findsOneWidget);
    });

    testWidgets('shows cumulative background label', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Cumulative Background'), findsOneWidget);
    });

    testWidgets('shows Background after transition', (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();

      await tester.pumpWidget(buildLifecycleTestWidget());

      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(_tick);

      expect(find.text('Background'), findsOneWidget);
      expect(find.text('Foreground'), findsNothing);
    });

    testWidgets('shows Foreground after returning from background',
        (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();

      await tester.pumpWidget(buildLifecycleTestWidget());

      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(_tick);

      tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump(_tick);

      expect(find.text('Foreground'), findsOneWidget);
    });
  });
}
