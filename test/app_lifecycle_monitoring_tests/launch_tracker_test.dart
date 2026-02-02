import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/lifecycle_demo/launch_tracker.dart';

import 'lifecycle_test_helpers.dart';

/// Initializes the tracker with a cold start and pumps until the
/// post-frame callback fires.
Future<void> initializeTrackerInTest(WidgetTester tester) async {
  final tracker = LaunchTracker.instance;
  tracker.recordMainStart(DateTime.now());
  await tester.pumpWidget(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(),
    ),
  );
  tracker.initialize();
  // Schedule a frame explicitly so the post-frame callback fires.
  SchedulerBinding.instance.scheduleFrame();
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('LaunchTracker - Cold Start', () {
    test('coldStartDurationMs is null before initialization', () {
      expect(LaunchTracker.instance.coldStartDurationMs, isNull);
    });

    test('recordMainStart stores the start time', () {
      LaunchTracker.instance.recordMainStart(DateTime(2025, 1, 1, 12, 0, 0));
      expect(LaunchTracker.instance.coldStartDurationMs, isNull);
    });

    testWidgets('initialize records cold start after first frame',
        (tester) async {
      await initializeTrackerInTest(tester);

      expect(
        LaunchTracker.instance.coldStartDurationMs,
        isNotNull,
      );
      expect(
        LaunchTracker.instance.coldStartDurationMs,
        greaterThanOrEqualTo(0),
      );
    });

    testWidgets('isFirstLaunch is false after cold start recorded',
        (tester) async {
      expect(LaunchTracker.instance.isFirstLaunch, isTrue);
      await initializeTrackerInTest(tester);
      expect(LaunchTracker.instance.isFirstLaunch, isFalse);
    });

    testWidgets('notifies listeners when cold start is recorded',
        (tester) async {
      final tracker = LaunchTracker.instance;
      var notified = false;
      void listener() => notified = true;
      tracker.addListener(listener);

      await initializeTrackerInTest(tester);

      expect(notified, isTrue);
      tracker.removeListener(listener);
    });
  });

  group('LaunchTracker - Warm Start', () {
    test('warmStarts is empty initially', () {
      expect(LaunchTracker.instance.warmStarts, isEmpty);
    });

    testWidgets('records warm start on paused then resumed', (tester) async {
      await initializeTrackerInTest(tester);

      final tracker = LaunchTracker.instance;
      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(tracker.warmStarts.length, 1);
      expect(tracker.warmStarts.first.durationMs, greaterThanOrEqualTo(0));
    });

    testWidgets('does not record warm start without prior pause',
        (tester) async {
      await initializeTrackerInTest(tester);

      final tracker = LaunchTracker.instance;
      tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(tracker.warmStarts, isEmpty);
    });

    test('reset clears all state', () {
      final tracker = LaunchTracker.instance;
      tracker.recordMainStart(DateTime(2025, 1, 1, 12, 0, 0));
      tracker.reset();

      expect(tracker.coldStartDurationMs, isNull);
      expect(tracker.isFirstLaunch, isTrue);
      expect(tracker.warmStarts, isEmpty);
    });
  });
}
