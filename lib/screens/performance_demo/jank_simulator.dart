import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class JankSimulator {
  JankSimulator._();

  static int _iterationsPerMs = 0;

  static void calibrateIterations() {
    const calibrationMs = 10;
    final sw = Stopwatch()..start();
    var count = 0;
    while (sw.elapsedMilliseconds < calibrationMs) {
      count++;
      // Busy work to prevent compiler optimization.
      count.hashCode;
    }
    sw.stop();
    _iterationsPerMs = count ~/ calibrationMs;
    if (_iterationsPerMs <= 0) _iterationsPerMs = 1;
  }

  static void causeJank(int durationMs) {
    if (_iterationsPerMs == 0) calibrateIterations();

    final span = FlutterOTel.tracer.startSpan(
      'app.jank_simulation',
      attributes: <String, Object>{
        'jank.target_duration_ms': durationMs,
      }.toAttributes(),
    );

    final iterations = _iterationsPerMs * durationMs;
    var accumulator = 0;
    for (var i = 0; i < iterations; i++) {
      accumulator += i.hashCode;
    }
    // Prevent dead-code elimination.
    accumulator.hashCode;

    span.end();
  }
}
