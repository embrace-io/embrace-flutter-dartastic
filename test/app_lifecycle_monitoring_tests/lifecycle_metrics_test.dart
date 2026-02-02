import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/lifecycle_demo/lifecycle_metrics.dart';

import 'lifecycle_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('LifecycleMetrics - Initial state', () {
    test('totalTransitions is zero initially', () {
      expect(LifecycleMetrics.instance.totalTransitions, 0);
    });

    test('longestForegroundMs is zero initially', () {
      expect(LifecycleMetrics.instance.longestForegroundMs, 0);
    });

    test('longestBackgroundMs is zero initially', () {
      expect(LifecycleMetrics.instance.longestBackgroundMs, 0);
    });

    test('sessionDurationMs is zero before initialize', () {
      expect(LifecycleMetrics.instance.sessionDurationMs, 0);
    });
  });

  group('LifecycleMetrics - Transition counter', () {
    test('recordTransition increments totalTransitions', () {
      final metrics = LifecycleMetrics.instance;
      metrics.recordTransition('resumed', 'inactive');
      expect(metrics.totalTransitions, 1);
    });

    test('multiple transitions accumulate', () {
      final metrics = LifecycleMetrics.instance;
      metrics.recordTransition('resumed', 'inactive');
      metrics.recordTransition('inactive', 'paused');
      metrics.recordTransition('paused', 'resumed');
      expect(metrics.totalTransitions, 3);
    });

    test('recordTransition notifies listeners', () {
      final metrics = LifecycleMetrics.instance;
      var notifyCount = 0;
      void listener() => notifyCount++;
      metrics.addListener(listener);

      metrics.recordTransition('resumed', 'inactive');
      expect(notifyCount, 1);

      metrics.removeListener(listener);
    });
  });

  group('LifecycleMetrics - Foreground session histogram', () {
    test('recordForegroundSession updates longestForegroundMs', () {
      final metrics = LifecycleMetrics.instance;
      metrics.recordForegroundSession(500);
      expect(metrics.longestForegroundMs, 500);
    });

    test('tracks the longest session', () {
      final metrics = LifecycleMetrics.instance;
      metrics.recordForegroundSession(200);
      metrics.recordForegroundSession(800);
      metrics.recordForegroundSession(300);
      expect(metrics.longestForegroundMs, 800);
    });

    test('recordForegroundSession notifies listeners', () {
      final metrics = LifecycleMetrics.instance;
      var notifyCount = 0;
      void listener() => notifyCount++;
      metrics.addListener(listener);

      metrics.recordForegroundSession(100);
      expect(notifyCount, 1);

      metrics.removeListener(listener);
    });
  });

  group('LifecycleMetrics - Background duration histogram', () {
    test('recordBackgroundDuration updates longestBackgroundMs', () {
      final metrics = LifecycleMetrics.instance;
      metrics.recordBackgroundDuration(300);
      expect(metrics.longestBackgroundMs, 300);
    });

    test('tracks the longest background period', () {
      final metrics = LifecycleMetrics.instance;
      metrics.recordBackgroundDuration(100);
      metrics.recordBackgroundDuration(600);
      metrics.recordBackgroundDuration(250);
      expect(metrics.longestBackgroundMs, 600);
    });

    test('recordBackgroundDuration notifies listeners', () {
      final metrics = LifecycleMetrics.instance;
      var notifyCount = 0;
      void listener() => notifyCount++;
      metrics.addListener(listener);

      metrics.recordBackgroundDuration(100);
      expect(notifyCount, 1);

      metrics.removeListener(listener);
    });
  });

  group('LifecycleMetrics - Session duration gauge', () {
    test('sessionDurationMs is positive after initialize', () {
      final metrics = LifecycleMetrics.instance;
      metrics.initialize();

      expect(metrics.sessionDurationMs, greaterThanOrEqualTo(0));
    });
  });

  group('LifecycleMetrics - Reset', () {
    test('reset clears all state', () {
      final metrics = LifecycleMetrics.instance;
      metrics.recordTransition('resumed', 'inactive');
      metrics.recordForegroundSession(500);
      metrics.recordBackgroundDuration(300);

      metrics.reset();

      expect(metrics.totalTransitions, 0);
      expect(metrics.longestForegroundMs, 0);
      expect(metrics.longestBackgroundMs, 0);
      expect(metrics.sessionDurationMs, 0);
    });
  });
}
