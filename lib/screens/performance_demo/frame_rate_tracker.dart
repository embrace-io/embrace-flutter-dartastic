import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'frame_metrics_exporter.dart';
import 'jank_detector.dart';

class FrameRateTracker extends ChangeNotifier {
  FrameRateTracker._();

  static final instance = FrameRateTracker._();

  static const _sparklineMaxLength = 30;
  static const _fpsWindowSize = 60;
  static const _averageWindowSeconds = 5;

  bool _isMonitoring = false;
  double _currentFps = 0;
  double _averageFps = 0;
  final List<double> _sparklineHistory = [];
  final List<Duration> _recentFrameDurations = [];
  final List<_TimestampedFps> _fpsReadings = [];

  bool get isMonitoring => _isMonitoring;
  double get currentFps => _currentFps;
  double get averageFps => _averageFps;
  List<double> get sparklineHistory => List.unmodifiable(_sparklineHistory);

  void start() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    notifyListeners();
  }

  void stop() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    notifyListeners();
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final totalDuration = timing.totalSpan;
      _recentFrameDurations.add(totalDuration);

      // Keep only last _fpsWindowSize frames
      if (_recentFrameDurations.length > _fpsWindowSize) {
        _recentFrameDurations.removeAt(0);
      }

      // Calculate current FPS from recent frames
      _currentFps = _calculateFps(_recentFrameDurations);

      // Track FPS over time for rolling average
      _fpsReadings.add(_TimestampedFps(DateTime.now(), _currentFps));
      _pruneOldReadings();
      _averageFps = _calculateRollingAverage();

      // Update sparkline
      _sparklineHistory.add(_currentFps);
      if (_sparklineHistory.length > _sparklineMaxLength) {
        _sparklineHistory.removeAt(0);
      }

      // Dispatch to JankDetector and FrameMetricsExporter
      final totalMs = totalDuration.inMicroseconds / 1000.0;
      JankDetector.instance.evaluateFrameDuration(totalMs);

      final buildMs =
          timing.buildDuration.inMicroseconds / 1000.0;
      final rasterMs =
          timing.rasterDuration.inMicroseconds / 1000.0;
      FrameMetricsExporter.instance.recordFrame(
        buildMs: buildMs,
        rasterMs: rasterMs,
        totalMs: totalMs,
      );
    }
    notifyListeners();
  }

  double _calculateFps(List<Duration> durations) {
    if (durations.isEmpty) return 0;
    final totalUs =
        durations.fold<int>(0, (sum, d) => sum + d.inMicroseconds);
    final avgFrameTimeSeconds = (totalUs / durations.length) / 1000000.0;
    if (avgFrameTimeSeconds <= 0) return 0;
    return 1.0 / avgFrameTimeSeconds;
  }

  void _pruneOldReadings() {
    final cutoff =
        DateTime.now().subtract(const Duration(seconds: _averageWindowSeconds));
    _fpsReadings.removeWhere((r) => r.timestamp.isBefore(cutoff));
  }

  double _calculateRollingAverage() {
    if (_fpsReadings.isEmpty) return 0;
    final sum = _fpsReadings.fold<double>(0, (s, r) => s + r.fps);
    return sum / _fpsReadings.length;
  }

  @visibleForTesting
  void reset() {
    if (_isMonitoring) {
      SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    }
    _isMonitoring = false;
    _currentFps = 0;
    _averageFps = 0;
    _sparklineHistory.clear();
    _recentFrameDurations.clear();
    _fpsReadings.clear();
  }
}

class _TimestampedFps {
  _TimestampedFps(this.timestamp, this.fps);
  final DateTime timestamp;
  final double fps;
}
