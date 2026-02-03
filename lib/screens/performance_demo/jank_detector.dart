import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart'
    show Counter, Histogram;
import 'package:flutter/widgets.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class JankDetector extends ChangeNotifier {
  JankDetector._();

  static final instance = JankDetector._();

  static const normalThresholdMs = 16;
  static const severeThresholdMs = 32;

  Counter<int>? _jankCounter;
  Histogram<double>? _frameDurationHistogram;

  int _normalFrames = 0;
  int _jankFrames = 0;
  int _severeFrames = 0;
  DateTime? _lastJankTimestamp;

  int get normalFrames => _normalFrames;
  int get jankFrames => _jankFrames;
  int get severeFrames => _severeFrames;
  DateTime? get lastJankTimestamp => _lastJankTimestamp;

  double get jankPercentage {
    final total = _normalFrames + _jankFrames + _severeFrames;
    if (total == 0) return 0.0;
    return (_jankFrames + _severeFrames) / total * 100;
  }

  void initialize() {
    final meter = FlutterOTel.meter();

    _jankCounter = meter.createCounter<int>(
      name: 'app.jank_frames',
      unit: '{frame}',
    );

    _frameDurationHistogram = meter.createHistogram<double>(
      name: 'app.frame_duration',
      unit: 'ms',
      boundaries: [8.0, 12.0, 16.0, 24.0, 32.0, 48.0, 64.0],
    );
  }

  void evaluateFrameDuration(double durationMs) {
    _frameDurationHistogram?.record(durationMs);

    if (durationMs > severeThresholdMs) {
      _severeFrames++;
      _lastJankTimestamp = DateTime.now();
      _jankCounter?.add(
        1,
        <String, Object>{'severity': 'severe'}.toAttributes(),
      );
    } else if (durationMs > normalThresholdMs) {
      _jankFrames++;
      _lastJankTimestamp = DateTime.now();
      _jankCounter?.add(
        1,
        <String, Object>{'severity': 'jank'}.toAttributes(),
      );
    } else {
      _normalFrames++;
    }
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _jankCounter = null;
    _frameDurationHistogram = null;
    _normalFrames = 0;
    _jankFrames = 0;
    _severeFrames = 0;
    _lastJankTimestamp = null;
  }
}
