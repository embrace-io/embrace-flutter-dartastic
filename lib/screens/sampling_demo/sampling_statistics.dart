import 'package:flutter/widgets.dart';

class SamplingStatistics extends ChangeNotifier {
  SamplingStatistics._();

  static final instance = SamplingStatistics._();

  int _spansCreated = 0;
  int _spansSampled = 0;

  int get spansCreated => _spansCreated;

  int get spansSampled => _spansSampled;

  int get spansDropped => _spansCreated - _spansSampled;

  double get sampleRate =>
      _spansCreated == 0 ? 0.0 : (_spansSampled / _spansCreated) * 100.0;

  void recordSpan({required bool wasSampled}) {
    _spansCreated++;
    if (wasSampled) {
      _spansSampled++;
    }
    notifyListeners();
  }

  void resetStatistics() {
    _spansCreated = 0;
    _spansSampled = 0;
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _spansCreated = 0;
    _spansSampled = 0;
  }
}
