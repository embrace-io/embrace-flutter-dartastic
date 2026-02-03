import 'package:flutter/widgets.dart';

class InteractionLogEntry {
  const InteractionLogEntry({
    required this.widgetType,
    required this.action,
    required this.timestamp,
    required this.spanId,
  });

  final String widgetType;
  final String action;
  final DateTime timestamp;
  final String spanId;
}

class InteractionLogStore extends ChangeNotifier {
  InteractionLogStore._();

  static final instance = InteractionLogStore._();

  static const maxEntries = 15;

  final List<InteractionLogEntry> _entries = [];

  List<InteractionLogEntry> get entries => List.unmodifiable(_entries);

  void recordInteraction(InteractionLogEntry entry) {
    _entries.insert(0, entry);

    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }

    notifyListeners();
  }

  void clearLog() {
    _entries.clear();
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _entries.clear();
  }
}
