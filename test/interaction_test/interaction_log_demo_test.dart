import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/interaction_demo/interaction_log_store.dart';

import 'interaction_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetInteractionTrackers();
  });

  group('InteractionLogDemo', () {
    testWidgets('displays empty state text when no interactions',
        (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      expect(
        find.text('No interactions recorded yet'),
        findsOneWidget,
      );
    });

    testWidgets('displays Clear Log button', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      expect(find.text('Clear Log'), findsOneWidget);
    });

    testWidgets('entries appear after recording an interaction',
        (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      InteractionLogStore.instance.recordInteraction(
        InteractionLogEntry(
          widgetType: 'Button',
          action: 'tap: test',
          timestamp: DateTime.now(),
          spanId: 'test-span-id',
        ),
      );
      await tester.pump();

      expect(find.text('Button: tap: test'), findsOneWidget);
    });

    testWidgets('Clear Log removes all entries', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      InteractionLogStore.instance.recordInteraction(
        InteractionLogEntry(
          widgetType: 'Button',
          action: 'tap: test',
          timestamp: DateTime.now(),
          spanId: 'test-span-id',
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Clear Log'));
      await tester.pump();

      expect(
        find.text('No interactions recorded yet'),
        findsOneWidget,
      );
    });
  });
}
