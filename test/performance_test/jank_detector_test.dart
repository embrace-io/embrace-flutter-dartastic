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

  group('JankDetector - Initial State', () {
    test('normalFrames is zero initially', () {
      expect(JankDetector.instance.normalFrames, 0);
    });

    test('jankFrames is zero initially', () {
      expect(JankDetector.instance.jankFrames, 0);
    });

    test('severeFrames is zero initially', () {
      expect(JankDetector.instance.severeFrames, 0);
    });

    test('jankPercentage is zero initially', () {
      expect(JankDetector.instance.jankPercentage, 0.0);
    });

    test('lastJankTimestamp is null initially', () {
      expect(JankDetector.instance.lastJankTimestamp, isNull);
    });
  });

  group('JankDetector - Frame Evaluation', () {
    test('frame under 16ms is classified as normal', () {
      final detector = JankDetector.instance;
      detector.evaluateFrameDuration(10.0);
      expect(detector.normalFrames, 1);
      expect(detector.jankFrames, 0);
      expect(detector.severeFrames, 0);
    });

    test('frame at exactly 16ms is classified as normal', () {
      final detector = JankDetector.instance;
      detector.evaluateFrameDuration(16.0);
      expect(detector.normalFrames, 1);
      expect(detector.jankFrames, 0);
    });

    test('frame over 16ms is classified as jank', () {
      final detector = JankDetector.instance;
      detector.evaluateFrameDuration(20.0);
      expect(detector.jankFrames, 1);
      expect(detector.normalFrames, 0);
      expect(detector.severeFrames, 0);
    });

    test('frame at exactly 32ms is classified as jank (not severe)', () {
      final detector = JankDetector.instance;
      detector.evaluateFrameDuration(32.0);
      expect(detector.jankFrames, 1);
      expect(detector.severeFrames, 0);
    });

    test('frame over 32ms is classified as severe', () {
      final detector = JankDetector.instance;
      detector.evaluateFrameDuration(50.0);
      expect(detector.severeFrames, 1);
      expect(detector.jankFrames, 0);
      expect(detector.normalFrames, 0);
    });

    test('jank percentage is calculated correctly', () {
      final detector = JankDetector.instance;
      // 8 normal + 1 jank + 1 severe = 20% jank
      for (var i = 0; i < 8; i++) {
        detector.evaluateFrameDuration(10.0);
      }
      detector.evaluateFrameDuration(20.0); // jank
      detector.evaluateFrameDuration(50.0); // severe
      expect(detector.jankPercentage, 20.0);
    });

    test('lastJankTimestamp is set on jank frame', () {
      final detector = JankDetector.instance;
      expect(detector.lastJankTimestamp, isNull);
      detector.evaluateFrameDuration(20.0);
      expect(detector.lastJankTimestamp, isNotNull);
    });

    test('lastJankTimestamp is set on severe frame', () {
      final detector = JankDetector.instance;
      detector.evaluateFrameDuration(50.0);
      expect(detector.lastJankTimestamp, isNotNull);
    });

    test('lastJankTimestamp is not set on normal frame', () {
      final detector = JankDetector.instance;
      detector.evaluateFrameDuration(10.0);
      expect(detector.lastJankTimestamp, isNull);
    });

    test('evaluateFrameDuration notifies listeners', () {
      final detector = JankDetector.instance;
      var notifyCount = 0;
      void listener() => notifyCount++;
      detector.addListener(listener);

      detector.evaluateFrameDuration(10.0);
      expect(notifyCount, 1);

      detector.removeListener(listener);
    });
  });

  group('JankDetector - Reset', () {
    test('reset clears all state', () {
      final detector = JankDetector.instance;
      detector.evaluateFrameDuration(10.0);
      detector.evaluateFrameDuration(20.0);
      detector.evaluateFrameDuration(50.0);

      detector.reset();

      expect(detector.normalFrames, 0);
      expect(detector.jankFrames, 0);
      expect(detector.severeFrames, 0);
      expect(detector.jankPercentage, 0.0);
      expect(detector.lastJankTimestamp, isNull);
    });
  });
}
