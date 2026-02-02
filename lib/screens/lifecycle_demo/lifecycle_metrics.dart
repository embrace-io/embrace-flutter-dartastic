import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart'
    show Counter, Histogram;
import 'package:flutter/widgets.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class LifecycleMetrics extends ChangeNotifier {
  LifecycleMetrics._();

  static final instance = LifecycleMetrics._();

  Counter<int>? _transitionCounter;
  Histogram<int>? _foregroundDurationHistogram;
  Histogram<int>? _backgroundDurationHistogram;
  DateTime? _launchTime;

  int _totalTransitions = 0;
  int _longestForegroundMs = 0;
  int _longestBackgroundMs = 0;

  int get totalTransitions => _totalTransitions;
  int get longestForegroundMs => _longestForegroundMs;
  int get longestBackgroundMs => _longestBackgroundMs;
  int get sessionDurationMs => _launchTime != null
      ? DateTime.now().difference(_launchTime!).inMilliseconds
      : 0;

  void initialize() {
    _launchTime = DateTime.now();

    final meter = FlutterOTel.meter();

    _transitionCounter = meter.createCounter<int>(
      name: 'app.lifecycle_transitions',
      unit: '{transition}',
    );

    _foregroundDurationHistogram = meter.createHistogram<int>(
      name: 'app.foreground_session_duration',
      unit: 'ms',
    );

    _backgroundDurationHistogram = meter.createHistogram<int>(
      name: 'app.background_duration',
      unit: 'ms',
    );

    meter.createObservableGauge<int>(
      name: 'app.session_duration',
      unit: 's',
      callback: (result) {
        if (_launchTime != null) {
          result.observe(
            DateTime.now().difference(_launchTime!).inSeconds,
          );
        }
      },
    );
  }

  void recordTransition(String previousState, String newState) {
    _totalTransitions++;
    _transitionCounter?.add(
      1,
      <String, Object>{
        'transition_type': '${previousState}_to_$newState',
      }.toAttributes(),
    );
    notifyListeners();
  }

  void recordForegroundSession(int durationMs) {
    _foregroundDurationHistogram?.record(durationMs);
    if (durationMs > _longestForegroundMs) {
      _longestForegroundMs = durationMs;
    }
    notifyListeners();
  }

  void recordBackgroundDuration(int durationMs) {
    _backgroundDurationHistogram?.record(durationMs);
    if (durationMs > _longestBackgroundMs) {
      _longestBackgroundMs = durationMs;
    }
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _transitionCounter = null;
    _foregroundDurationHistogram = null;
    _backgroundDurationHistogram = null;
    _launchTime = null;
    _totalTransitions = 0;
    _longestForegroundMs = 0;
    _longestBackgroundMs = 0;
  }
}
