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

  group('FrameRateTracker - Initial State', () {
    test('isMonitoring is false initially', () {
      expect(FrameRateTracker.instance.isMonitoring, isFalse);
    });

    test('currentFps is zero initially', () {
      expect(FrameRateTracker.instance.currentFps, 0);
    });

    test('averageFps is zero initially', () {
      expect(FrameRateTracker.instance.averageFps, 0);
    });

    test('sparklineHistory is empty initially', () {
      expect(FrameRateTracker.instance.sparklineHistory, isEmpty);
    });
  });

  group('FrameRateTracker - Start/Stop', () {
    test('start sets isMonitoring to true', () {
      final tracker = FrameRateTracker.instance;
      tracker.start();
      expect(tracker.isMonitoring, isTrue);
      tracker.stop();
    });

    test('stop sets isMonitoring to false', () {
      final tracker = FrameRateTracker.instance;
      tracker.start();
      tracker.stop();
      expect(tracker.isMonitoring, isFalse);
    });

    test('start notifies listeners', () {
      final tracker = FrameRateTracker.instance;
      var notifyCount = 0;
      void listener() => notifyCount++;
      tracker.addListener(listener);

      tracker.start();
      expect(notifyCount, 1);

      tracker.stop();
      tracker.removeListener(listener);
    });

    test('stop notifies listeners', () {
      final tracker = FrameRateTracker.instance;
      tracker.start();

      var notifyCount = 0;
      void listener() => notifyCount++;
      tracker.addListener(listener);

      tracker.stop();
      expect(notifyCount, 1);

      tracker.removeListener(listener);
    });

    test('double start does not re-register callback', () {
      final tracker = FrameRateTracker.instance;
      var notifyCount = 0;
      void listener() => notifyCount++;
      tracker.addListener(listener);

      tracker.start();
      tracker.start(); // second call should be no-op
      expect(notifyCount, 1); // only one notification from first start

      tracker.stop();
      tracker.removeListener(listener);
    });
  });

  group('FrameRateTracker - Reset', () {
    test('reset clears all state', () {
      final tracker = FrameRateTracker.instance;
      tracker.start();
      tracker.reset();

      expect(tracker.isMonitoring, isFalse);
      expect(tracker.currentFps, 0);
      expect(tracker.averageFps, 0);
      expect(tracker.sparklineHistory, isEmpty);
    });
  });
}
