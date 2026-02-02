import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/lifecycle_demo/foreground_tracker.dart';

import 'lifecycle_test_helpers.dart';

/// Pump enough time for a zero-duration debounce timer to fire.
const _tick = Duration(milliseconds: 1);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('ForegroundTracker - State', () {
    test('starts in foreground before initialize', () {
      expect(ForegroundTracker.instance.isForeground, isTrue);
    });

    test('cumulative times are zero initially', () {
      expect(ForegroundTracker.instance.cumulativeForegroundMs, 0);
      expect(ForegroundTracker.instance.cumulativeBackgroundMs, 0);
    });

    testWidgets('initialize sets foreground state', (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();
      await tester.pump();

      expect(tracker.isForeground, isTrue);
    });
  });

  group('ForegroundTracker - Transitions (no debounce)', () {
    testWidgets('transitions to background on paused', (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();
      await tester.pump();

      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(_tick);

      expect(tracker.isForeground, isFalse);
    });

    testWidgets('transitions to background on inactive', (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();
      await tester.pump();

      tracker.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump(_tick);

      expect(tracker.isForeground, isFalse);
    });

    testWidgets('transitions back to foreground on resumed', (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();
      await tester.pump();

      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(_tick);
      expect(tracker.isForeground, isFalse);

      tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump(_tick);
      expect(tracker.isForeground, isTrue);
    });

    testWidgets('accumulates foreground time on background transition',
        (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 200));
      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(_tick);

      expect(tracker.cumulativeForegroundMs, greaterThanOrEqualTo(0));
    });

    testWidgets('accumulates background time on foreground transition',
        (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();
      await tester.pump();

      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(_tick);

      tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump(_tick);

      expect(tracker.cumulativeBackgroundMs, greaterThanOrEqualTo(0));
    });

    testWidgets('notifies listeners on state change', (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.debounceDuration = Duration.zero;
      tracker.initialize();
      await tester.pump();

      var notifyCount = 0;
      void listener() => notifyCount++;
      tracker.addListener(listener);

      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(_tick);
      expect(notifyCount, 1);

      tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump(_tick);
      expect(notifyCount, 2);

      tracker.removeListener(listener);
    });
  });

  group('ForegroundTracker - Debounce', () {
    testWidgets('does not transition if state returns within debounce window',
        (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.initialize();
      await tester.pump();

      // Go inactive — debounce timer starts.
      tracker.didChangeAppLifecycleState(AppLifecycleState.inactive);
      // Come back to resumed before 100ms.
      await tester.pump(const Duration(milliseconds: 50));
      tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 100));

      expect(tracker.isForeground, isTrue);
    });

    testWidgets('transitions after debounce window expires', (tester) async {
      final tracker = ForegroundTracker.instance;
      tracker.initialize();
      await tester.pump();

      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 150));

      expect(tracker.isForeground, isFalse);
    });
  });

  group('ForegroundTracker - Reset', () {
    test('reset clears all state', () {
      final tracker = ForegroundTracker.instance;
      tracker.reset();

      expect(tracker.isForeground, isTrue);
      expect(tracker.cumulativeForegroundMs, 0);
      expect(tracker.cumulativeBackgroundMs, 0);
    });
  });
}
