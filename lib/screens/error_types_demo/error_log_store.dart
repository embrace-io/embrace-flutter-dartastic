import 'package:flutter/widgets.dart';

class ErrorLogEntry {
  const ErrorLogEntry({
    required this.errorType,
    required this.message,
    required this.timestamp,
    required this.source,
  });

  final String errorType;
  final String message;
  final DateTime timestamp;

  /// One of "sync", "async", "flutter", or "context".
  final String source;
}

class ErrorLogStore extends ChangeNotifier {
  ErrorLogStore._();

  static final instance = ErrorLogStore._();

  static const maxEntries = 50;

  final List<ErrorLogEntry> _entries = [];

  List<ErrorLogEntry> get entries => List.unmodifiable(_entries);

  void addEntry(ErrorLogEntry entry) {
    _entries.insert(0, entry);

    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }

    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _entries.clear();
  }
}
