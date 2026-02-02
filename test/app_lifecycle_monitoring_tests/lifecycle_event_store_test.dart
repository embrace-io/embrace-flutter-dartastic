import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/lifecycle_demo/lifecycle_event_store.dart';

import 'lifecycle_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('LifecycleEventStore', () {
    test('starts with resumed state and empty transitions', () {
      final store = LifecycleEventStore.instance;
      expect(store.currentState, AppLifecycleState.resumed);
      expect(store.transitions, isEmpty);
    });

    test('recordTransition updates current state', () {
      final store = LifecycleEventStore.instance;
      store.recordTransition(
        AppLifecycleState.inactive,
        DateTime(2025, 1, 1, 12, 0, 0),
      );
      expect(store.currentState, AppLifecycleState.inactive);
    });

    test('recordTransition adds to transitions list newest first', () {
      final store = LifecycleEventStore.instance;
      store.recordTransition(
        AppLifecycleState.inactive,
        DateTime(2025, 1, 1, 12, 0, 0),
      );
      store.recordTransition(
        AppLifecycleState.paused,
        DateTime(2025, 1, 1, 12, 0, 5),
      );
      expect(store.transitions.length, 2);
      expect(store.transitions.first.next, AppLifecycleState.paused);
      expect(store.transitions.last.next, AppLifecycleState.inactive);
    });

    test('first transition has no durationSinceLastEvent', () {
      final store = LifecycleEventStore.instance;
      store.recordTransition(
        AppLifecycleState.inactive,
        DateTime(2025, 1, 1, 12, 0, 0),
      );
      expect(store.transitions.first.durationSinceLastEvent, isNull);
    });

    test('subsequent transitions compute durationSinceLastEvent', () {
      final store = LifecycleEventStore.instance;
      store.recordTransition(
        AppLifecycleState.inactive,
        DateTime(2025, 1, 1, 12, 0, 0),
      );
      store.recordTransition(
        AppLifecycleState.paused,
        DateTime(2025, 1, 1, 12, 0, 3),
      );
      expect(
        store.transitions.first.durationSinceLastEvent,
        const Duration(seconds: 3),
      );
    });

    test('clearLog removes all transitions', () {
      final store = LifecycleEventStore.instance;
      store.recordTransition(
        AppLifecycleState.inactive,
        DateTime(2025, 1, 1, 12, 0, 0),
      );
      store.clearLog();
      expect(store.transitions, isEmpty);
    });

    test('caps transitions at maxEvents', () {
      final store = LifecycleEventStore.instance;
      for (int i = 0; i < LifecycleEventStore.maxEvents + 10; i++) {
        store.recordTransition(
          i.isEven ? AppLifecycleState.inactive : AppLifecycleState.resumed,
          DateTime(2025, 1, 1, 12, 0, i),
        );
      }
      expect(store.transitions.length, LifecycleEventStore.maxEvents);
    });

    test('notifies listeners on recordTransition', () {
      final store = LifecycleEventStore.instance;
      var notified = false;
      store.addListener(() => notified = true);
      store.recordTransition(
        AppLifecycleState.inactive,
        DateTime(2025, 1, 1, 12, 0, 0),
      );
      expect(notified, isTrue);
      store.removeListener(() => notified = true);
    });

    test('notifies listeners on clearLog', () {
      final store = LifecycleEventStore.instance;
      store.recordTransition(
        AppLifecycleState.inactive,
        DateTime(2025, 1, 1, 12, 0, 0),
      );
      var notified = false;
      void listener() => notified = true;
      store.addListener(listener);
      store.clearLog();
      expect(notified, isTrue);
      store.removeListener(listener);
    });
  });

  group('LifecycleObserverDemo - Event Display', () {
    testWidgets('first transition has no duration label', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      // First transition should not show a +duration label
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('events persist after widget rebuild', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.textContaining('resumed → inactive'), findsOneWidget);

      // Rebuild the widget tree (simulates navigating away and back)
      await tester.pumpWidget(buildLifecycleTestWidget());

      // Events should still be visible from the singleton store
      expect(find.textContaining('resumed → inactive'), findsOneWidget);
    });
  });
}
