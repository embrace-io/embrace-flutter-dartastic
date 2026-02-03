import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/interaction_demo/interaction_log_store.dart';

void main() {
  setUp(() {
    InteractionLogStore.instance.reset();
  });

  group('InteractionLogStore', () {
    test('starts with empty entries', () {
      expect(InteractionLogStore.instance.entries, isEmpty);
    });

    test('recordInteraction adds entry', () {
      final entry = InteractionLogEntry(
        widgetType: 'Button',
        action: 'tap',
        timestamp: DateTime.now(),
        spanId: 'span-1',
      );

      InteractionLogStore.instance.recordInteraction(entry);

      expect(InteractionLogStore.instance.entries.length, 1);
      expect(InteractionLogStore.instance.entries.first.widgetType, 'Button');
    });

    test('newest entries are inserted at index 0', () {
      final first = InteractionLogEntry(
        widgetType: 'Button',
        action: 'tap',
        timestamp: DateTime.now(),
        spanId: 'span-1',
      );
      final second = InteractionLogEntry(
        widgetType: 'Gesture',
        action: 'longPress',
        timestamp: DateTime.now(),
        spanId: 'span-2',
      );

      InteractionLogStore.instance.recordInteraction(first);
      InteractionLogStore.instance.recordInteraction(second);

      expect(
        InteractionLogStore.instance.entries.first.widgetType,
        'Gesture',
      );
    });

    test('caps entries at 15', () {
      for (var i = 0; i < 20; i++) {
        InteractionLogStore.instance.recordInteraction(
          InteractionLogEntry(
            widgetType: 'Widget-$i',
            action: 'tap',
            timestamp: DateTime.now(),
            spanId: 'span-$i',
          ),
        );
      }

      expect(
        InteractionLogStore.instance.entries.length,
        InteractionLogStore.maxEntries,
      );
    });

    test('clearLog removes all entries', () {
      InteractionLogStore.instance.recordInteraction(
        InteractionLogEntry(
          widgetType: 'Button',
          action: 'tap',
          timestamp: DateTime.now(),
          spanId: 'span-1',
        ),
      );

      InteractionLogStore.instance.clearLog();

      expect(InteractionLogStore.instance.entries, isEmpty);
    });

    test('reset clears entries', () {
      InteractionLogStore.instance.recordInteraction(
        InteractionLogEntry(
          widgetType: 'Button',
          action: 'tap',
          timestamp: DateTime.now(),
          spanId: 'span-1',
        ),
      );

      InteractionLogStore.instance.reset();

      expect(InteractionLogStore.instance.entries, isEmpty);
    });

    test('notifies listeners on recordInteraction', () {
      var notified = false;
      InteractionLogStore.instance.addListener(() => notified = true);

      InteractionLogStore.instance.recordInteraction(
        InteractionLogEntry(
          widgetType: 'Button',
          action: 'tap',
          timestamp: DateTime.now(),
          spanId: 'span-1',
        ),
      );

      expect(notified, isTrue);

      InteractionLogStore.instance.removeListener(() {});
    });

    test('notifies listeners on clearLog', () {
      InteractionLogStore.instance.recordInteraction(
        InteractionLogEntry(
          widgetType: 'Button',
          action: 'tap',
          timestamp: DateTime.now(),
          spanId: 'span-1',
        ),
      );

      var notified = false;
      InteractionLogStore.instance.addListener(() => notified = true);

      InteractionLogStore.instance.clearLog();

      expect(notified, isTrue);

      InteractionLogStore.instance.removeListener(() {});
    });
  });
}
