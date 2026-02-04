import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/sampling_demo/sampling_statistics.dart';

void main() {
  setUp(() {
    SamplingStatistics.instance.reset();
  });

  group('SamplingStatistics', () {
    test('starts with zero counts', () {
      expect(SamplingStatistics.instance.spansCreated, 0);
      expect(SamplingStatistics.instance.spansSampled, 0);
      expect(SamplingStatistics.instance.spansDropped, 0);
      expect(SamplingStatistics.instance.sampleRate, 0.0);
    });

    test('recordSpan increments spansCreated', () {
      SamplingStatistics.instance.recordSpan(wasSampled: true);

      expect(SamplingStatistics.instance.spansCreated, 1);
    });

    test('recordSpan with wasSampled true increments spansSampled', () {
      SamplingStatistics.instance.recordSpan(wasSampled: true);

      expect(SamplingStatistics.instance.spansSampled, 1);
    });

    test('recordSpan with wasSampled false does not increment spansSampled',
        () {
      SamplingStatistics.instance.recordSpan(wasSampled: false);

      expect(SamplingStatistics.instance.spansSampled, 0);
    });

    test('spansDropped equals spansCreated minus spansSampled', () {
      SamplingStatistics.instance.recordSpan(wasSampled: true);
      SamplingStatistics.instance.recordSpan(wasSampled: false);
      SamplingStatistics.instance.recordSpan(wasSampled: false);

      expect(SamplingStatistics.instance.spansDropped, 2);
    });

    test('sampleRate computes correct percentage', () {
      SamplingStatistics.instance.recordSpan(wasSampled: true);
      SamplingStatistics.instance.recordSpan(wasSampled: false);

      expect(SamplingStatistics.instance.sampleRate, 50.0);
    });

    test('sampleRate is 100 when all spans are sampled', () {
      SamplingStatistics.instance.recordSpan(wasSampled: true);
      SamplingStatistics.instance.recordSpan(wasSampled: true);
      SamplingStatistics.instance.recordSpan(wasSampled: true);

      expect(SamplingStatistics.instance.sampleRate, 100.0);
    });

    test('sampleRate is 0 when no spans are sampled', () {
      SamplingStatistics.instance.recordSpan(wasSampled: false);
      SamplingStatistics.instance.recordSpan(wasSampled: false);

      expect(SamplingStatistics.instance.sampleRate, 0.0);
    });

    test('resetStatistics clears all counters', () {
      SamplingStatistics.instance.recordSpan(wasSampled: true);
      SamplingStatistics.instance.recordSpan(wasSampled: false);

      SamplingStatistics.instance.resetStatistics();

      expect(SamplingStatistics.instance.spansCreated, 0);
      expect(SamplingStatistics.instance.spansSampled, 0);
      expect(SamplingStatistics.instance.spansDropped, 0);
      expect(SamplingStatistics.instance.sampleRate, 0.0);
    });

    test('notifies listeners on recordSpan', () {
      var notified = false;
      SamplingStatistics.instance.addListener(() => notified = true);

      SamplingStatistics.instance.recordSpan(wasSampled: true);

      expect(notified, isTrue);

      SamplingStatistics.instance.removeListener(() {});
    });

    test('notifies listeners on resetStatistics', () {
      SamplingStatistics.instance.recordSpan(wasSampled: true);

      var notified = false;
      SamplingStatistics.instance.addListener(() => notified = true);

      SamplingStatistics.instance.resetStatistics();

      expect(notified, isTrue);

      SamplingStatistics.instance.removeListener(() {});
    });
  });
}
