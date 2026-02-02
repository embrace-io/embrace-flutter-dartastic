import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'lifecycle_metrics.dart';

class ForegroundTracker extends ChangeNotifier with WidgetsBindingObserver {
  ForegroundTracker._();

  static final instance = ForegroundTracker._();

  static const defaultDebounceDuration = Duration(milliseconds: 100);

  Duration _debounceDuration = defaultDebounceDuration;
  bool _isForeground = true;
  DateTime? _foregroundSessionStart;
  DateTime? _backgroundStart;
  Span? _foregroundSpan;
  int _cumulativeForegroundMs = 0;
  int _cumulativeBackgroundMs = 0;
  Timer? _debounceTimer;

  bool get isForeground => _isForeground;
  int get cumulativeForegroundMs => _cumulativeForegroundMs;
  int get cumulativeBackgroundMs => _cumulativeBackgroundMs;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _foregroundSessionStart = DateTime.now();
    _foregroundSpan = FlutterOTel.tracer.startSpan('app.foreground_session');
    _isForeground = true;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isForeground && state != AppLifecycleState.resumed) {
      // Leaving foreground — debounce to filter rapid transitions.
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, () {
        _commitBackgroundTransition();
      });
    } else if (!_isForeground && state == AppLifecycleState.resumed) {
      // Returning to foreground — commit immediately and cancel any
      // pending background debounce (shouldn't normally exist, but safe).
      _debounceTimer?.cancel();
      _debounceTimer = null;
      _commitForegroundTransition();
    } else if (_isForeground && state == AppLifecycleState.resumed) {
      // Still in foreground (e.g. inactive → resumed bounce) — cancel
      // any pending background transition.
      _debounceTimer?.cancel();
      _debounceTimer = null;
    }
  }

  void _commitBackgroundTransition() {
    _debounceTimer = null;
    final now = DateTime.now();

    _foregroundSpan?.end();
    _foregroundSpan = null;

    if (_foregroundSessionStart != null) {
      final fgDurationMs =
          now.difference(_foregroundSessionStart!).inMilliseconds;
      _cumulativeForegroundMs += fgDurationMs;
      LifecycleMetrics.instance.recordForegroundSession(fgDurationMs);
    }

    _backgroundStart = now;
    _isForeground = false;
    notifyListeners();
  }

  void _commitForegroundTransition() {
    final now = DateTime.now();

    if (_backgroundStart != null) {
      final bgDurationMs =
          now.difference(_backgroundStart!).inMilliseconds;
      _cumulativeBackgroundMs += bgDurationMs;
      LifecycleMetrics.instance.recordBackgroundDuration(bgDurationMs);
    }

    _foregroundSessionStart = now;
    _foregroundSpan = FlutterOTel.tracer.startSpan('app.foreground_session');
    _backgroundStart = null;
    _isForeground = true;
    notifyListeners();
  }

  @visibleForTesting
  set debounceDuration(Duration duration) {
    _debounceDuration = duration;
  }

  @visibleForTesting
  void reset() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _foregroundSpan = null;
    _foregroundSessionStart = null;
    _backgroundStart = null;
    _isForeground = true;
    _cumulativeForegroundMs = 0;
    _cumulativeBackgroundMs = 0;
    _debounceDuration = defaultDebounceDuration;
  }
}
