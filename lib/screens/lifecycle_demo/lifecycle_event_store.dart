import 'package:flutter/widgets.dart';

import 'lifecycle_metrics.dart';

class LifecycleTransition {
  const LifecycleTransition({
    required this.previous,
    required this.next,
    required this.timestamp,
    this.durationSinceLastEvent,
  });

  final AppLifecycleState previous;
  final AppLifecycleState next;
  final DateTime timestamp;
  final Duration? durationSinceLastEvent;
}

class LifecycleEventStore extends ChangeNotifier {
  LifecycleEventStore._();

  static final instance = LifecycleEventStore._();

  static const maxEvents = 50;

  AppLifecycleState _currentState = AppLifecycleState.resumed;
  final List<LifecycleTransition> _transitions = [];

  AppLifecycleState get currentState => _currentState;
  List<LifecycleTransition> get transitions =>
      List.unmodifiable(_transitions);

  void recordTransition(AppLifecycleState newState, DateTime timestamp) {
    final previous = _currentState;
    final durationSinceLast = _transitions.isEmpty
        ? null
        : timestamp.difference(_transitions.first.timestamp);

    _currentState = newState;
    LifecycleMetrics.instance.recordTransition(previous.name, newState.name);
    _transitions.insert(
      0,
      LifecycleTransition(
        previous: previous,
        next: newState,
        timestamp: timestamp,
        durationSinceLastEvent: durationSinceLast,
      ),
    );

    if (_transitions.length > maxEvents) {
      _transitions.removeRange(maxEvents, _transitions.length);
    }

    notifyListeners();
  }

  void clearLog() {
    _transitions.clear();
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _currentState = AppLifecycleState.resumed;
    _transitions.clear();
  }
}
