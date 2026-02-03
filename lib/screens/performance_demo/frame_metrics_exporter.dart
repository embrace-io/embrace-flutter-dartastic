import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart'
    show Histogram;
import 'package:flutter/widgets.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class FrameMetricsExporter extends ChangeNotifier {
  FrameMetricsExporter._();

  static final instance = FrameMetricsExporter._();

  static const _boundaries = [8.0, 12.0, 16.0, 24.0, 32.0, 48.0, 64.0];
  static const budgetMs = 16.0;

  Histogram<double>? _buildHistogram;
  Histogram<double>? _rasterHistogram;
  Histogram<double>? _totalHistogram;

  final List<double> _buildTimes = [];
  final List<double> _rasterTimes = [];
  final List<double> _totalTimes = [];

  int get sampleCount => _totalTimes.length;

  double get buildP50 => _percentile(_buildTimes, 0.50);
  double get buildP90 => _percentile(_buildTimes, 0.90);
  double get buildP95 => _percentile(_buildTimes, 0.95);
  double get buildP99 => _percentile(_buildTimes, 0.99);

  double get rasterP50 => _percentile(_rasterTimes, 0.50);
  double get rasterP90 => _percentile(_rasterTimes, 0.90);
  double get rasterP95 => _percentile(_rasterTimes, 0.95);
  double get rasterP99 => _percentile(_rasterTimes, 0.99);

  double get totalP50 => _percentile(_totalTimes, 0.50);
  double get totalP90 => _percentile(_totalTimes, 0.90);
  double get totalP95 => _percentile(_totalTimes, 0.95);
  double get totalP99 => _percentile(_totalTimes, 0.99);

  double get budgetUtilization {
    if (_totalTimes.isEmpty) return 0.0;
    final avg =
        _totalTimes.reduce((a, b) => a + b) / _totalTimes.length;
    return (avg / budgetMs) * 100;
  }

  void initialize() {
    final meter = FlutterOTel.meter();

    _buildHistogram = meter.createHistogram<double>(
      name: 'app.frame_build_time',
      unit: 'ms',
      boundaries: _boundaries,
    );

    _rasterHistogram = meter.createHistogram<double>(
      name: 'app.frame_raster_time',
      unit: 'ms',
      boundaries: _boundaries,
    );

    _totalHistogram = meter.createHistogram<double>(
      name: 'app.frame_total_time',
      unit: 'ms',
      boundaries: _boundaries,
    );
  }

  void recordFrame({
    required double buildMs,
    required double rasterMs,
    required double totalMs,
  }) {
    _buildHistogram?.record(buildMs);
    _rasterHistogram?.record(rasterMs);
    _totalHistogram?.record(totalMs);

    _insertSorted(_buildTimes, buildMs);
    _insertSorted(_rasterTimes, rasterMs);
    _insertSorted(_totalTimes, totalMs);

    notifyListeners();
  }

  void resetDisplay() {
    _buildTimes.clear();
    _rasterTimes.clear();
    _totalTimes.clear();
    notifyListeners();
  }

  double _percentile(List<double> sorted, double p) {
    if (sorted.isEmpty) return 0.0;
    final index = (p * (sorted.length - 1)).round();
    return sorted[index];
  }

  void _insertSorted(List<double> list, double value) {
    var lo = 0;
    var hi = list.length;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (list[mid] < value) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    list.insert(lo, value);
  }

  @visibleForTesting
  void reset() {
    _buildHistogram = null;
    _rasterHistogram = null;
    _totalHistogram = null;
    _buildTimes.clear();
    _rasterTimes.clear();
    _totalTimes.clear();
  }
}
