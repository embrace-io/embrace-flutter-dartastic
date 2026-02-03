import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/error_types_demo/error_log_store.dart';

void main() {
  setUp(() {
    ErrorLogStore.instance.reset();
  });

  group('ErrorLogStore', () {
    test('starts with empty entries', () {
      expect(ErrorLogStore.instance.entries, isEmpty);
    });

    test('addEntry adds entry', () {
      final entry = ErrorLogEntry(
        errorType: 'Exception',
        message: 'test error',
        timestamp: DateTime.now(),
        source: 'sync',
      );

      ErrorLogStore.instance.addEntry(entry);

      expect(ErrorLogStore.instance.entries.length, 1);
      expect(ErrorLogStore.instance.entries.first.errorType, 'Exception');
    });

    test('newest entries are inserted at index 0', () {
      final first = ErrorLogEntry(
        errorType: 'Exception',
        message: 'first',
        timestamp: DateTime.now(),
        source: 'sync',
      );
      final second = ErrorLogEntry(
        errorType: 'StateError',
        message: 'second',
        timestamp: DateTime.now(),
        source: 'async',
      );

      ErrorLogStore.instance.addEntry(first);
      ErrorLogStore.instance.addEntry(second);

      expect(
        ErrorLogStore.instance.entries.first.errorType,
        'StateError',
      );
    });

    test('entries contain correct fields', () {
      final now = DateTime.now();
      final entry = ErrorLogEntry(
        errorType: 'FormatException',
        message: 'bad format',
        timestamp: now,
        source: 'async',
      );

      ErrorLogStore.instance.addEntry(entry);

      final stored = ErrorLogStore.instance.entries.first;
      expect(stored.errorType, 'FormatException');
      expect(stored.message, 'bad format');
      expect(stored.timestamp, now);
      expect(stored.source, 'async');
    });

    test('caps entries at maxEntries', () {
      for (var i = 0; i < 60; i++) {
        ErrorLogStore.instance.addEntry(
          ErrorLogEntry(
            errorType: 'Error-$i',
            message: 'message $i',
            timestamp: DateTime.now(),
            source: 'sync',
          ),
        );
      }

      expect(
        ErrorLogStore.instance.entries.length,
        ErrorLogStore.maxEntries,
      );
    });

    test('clear removes all entries', () {
      ErrorLogStore.instance.addEntry(
        ErrorLogEntry(
          errorType: 'Exception',
          message: 'test',
          timestamp: DateTime.now(),
          source: 'sync',
        ),
      );

      ErrorLogStore.instance.clear();

      expect(ErrorLogStore.instance.entries, isEmpty);
    });

    test('reset clears entries', () {
      ErrorLogStore.instance.addEntry(
        ErrorLogEntry(
          errorType: 'Exception',
          message: 'test',
          timestamp: DateTime.now(),
          source: 'sync',
        ),
      );

      ErrorLogStore.instance.reset();

      expect(ErrorLogStore.instance.entries, isEmpty);
    });

    test('notifies listeners on addEntry', () {
      var notified = false;
      ErrorLogStore.instance.addListener(() => notified = true);

      ErrorLogStore.instance.addEntry(
        ErrorLogEntry(
          errorType: 'Exception',
          message: 'test',
          timestamp: DateTime.now(),
          source: 'sync',
        ),
      );

      expect(notified, isTrue);

      ErrorLogStore.instance.removeListener(() {});
    });

    test('notifies listeners on clear', () {
      ErrorLogStore.instance.addEntry(
        ErrorLogEntry(
          errorType: 'Exception',
          message: 'test',
          timestamp: DateTime.now(),
          source: 'sync',
        ),
      );

      var notified = false;
      ErrorLogStore.instance.addListener(() => notified = true);

      ErrorLogStore.instance.clear();

      expect(notified, isTrue);

      ErrorLogStore.instance.removeListener(() {});
    });
  });
}
