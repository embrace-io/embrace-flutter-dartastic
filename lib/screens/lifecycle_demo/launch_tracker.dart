import 'package:flutter/widgets.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class WarmStart {
  const WarmStart({
    required this.durationMs,
    required this.timestamp,
  });

  final int durationMs;
  final DateTime timestamp;
}

class LaunchTracker extends ChangeNotifier with WidgetsBindingObserver {
  LaunchTracker._();

  static final instance = LaunchTracker._();

  DateTime? _mainStartTime;
  DateTime? _firstFrameTime;
  int? _coldStartDurationMs;
  bool _isFirstLaunch = true;
  DateTime? _lastBackgroundedAt;
  final List<WarmStart> _warmStarts = [];

  int? get coldStartDurationMs => _coldStartDurationMs;
  bool get isFirstLaunch => _isFirstLaunch;
  List<WarmStart> get warmStarts => List.unmodifiable(_warmStarts);

  void recordMainStart(DateTime timestamp) {
    _mainStartTime = timestamp;
  }

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordFirstFrame();
    });
  }

  void _recordFirstFrame() {
    if (_mainStartTime == null || _firstFrameTime != null) return;
    _firstFrameTime = DateTime.now();
    _coldStartDurationMs =
        _firstFrameTime!.difference(_mainStartTime!).inMilliseconds;

    final span = FlutterOTel.tracer.startSpan('app.cold_start');
    span.setIntAttribute('cold_start_duration_ms', _coldStartDurationMs!);
    span.setBoolAttribute('is_first_launch', true);
    span.setStringAttribute('launch_type', 'cold');
    span.end();

    _isFirstLaunch = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _lastBackgroundedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed &&
        _lastBackgroundedAt != null) {
      final now = DateTime.now();
      final durationMs = now.difference(_lastBackgroundedAt!).inMilliseconds;

      final span = FlutterOTel.tracer.startSpan('app.warm_start');
      span.setIntAttribute('warm_start_duration_ms', durationMs);
      span.setBoolAttribute('is_first_launch', false);
      span.setStringAttribute('launch_type', 'warm');
      span.end();

      _warmStarts.insert(0, WarmStart(durationMs: durationMs, timestamp: now));
      _lastBackgroundedAt = null;
      notifyListeners();
    }
  }

  @visibleForTesting
  void reset() {
    _mainStartTime = null;
    _firstFrameTime = null;
    _coldStartDurationMs = null;
    _isFirstLaunch = true;
    _lastBackgroundedAt = null;
    _warmStarts.clear();
  }
}
