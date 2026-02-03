import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/interaction_demo/interaction_log_store.dart';
import 'package:embrace_flutter_dartastic/screens/interaction_demo/traced_gesture_demo.dart';

import 'interaction_test_helpers.dart';

/// Builds the gesture demo in isolation so the gesture area is on-screen.
Widget _buildGestureTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: TracedGestureDemo(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetInteractionTrackers();
  });

  group('TracedGestureDemo', () {
    testWidgets('displays gesture area', (tester) async {
      await tester.pumpWidget(_buildGestureTestWidget());

      expect(
        find.text('Gesture Area\nTap, long-press, double-tap, or drag'),
        findsOneWidget,
      );
    });

    testWidgets('displays last gesture label', (tester) async {
      await tester.pumpWidget(_buildGestureTestWidget());

      expect(find.text('Last gesture: None'), findsOneWidget);
    });

    testWidgets('tap updates label and logs interaction', (tester) async {
      await tester.pumpWidget(_buildGestureTestWidget());

      await tester.tap(
        find.text('Gesture Area\nTap, long-press, double-tap, or drag'),
      );
      // Wait past the double-tap deadline (300ms) so the tap is recognized.
      await tester.pump(const Duration(milliseconds: 500));
      // Settle remaining timers (flash color animation).
      await tester.pumpAndSettle();

      expect(find.text('Last gesture: tap'), findsOneWidget);

      final entries = InteractionLogStore.instance.entries;
      expect(entries.any((e) => e.action.contains('tap')), isTrue);
    });

    testWidgets('long-press updates label and logs interaction',
        (tester) async {
      await tester.pumpWidget(_buildGestureTestWidget());

      await tester.longPress(
        find.text('Gesture Area\nTap, long-press, double-tap, or drag'),
      );
      // pumpAndSettle resolves the flash color timer.
      await tester.pumpAndSettle();

      expect(find.text('Last gesture: longPress'), findsOneWidget);

      final entries = InteractionLogStore.instance.entries;
      expect(
        entries.any((e) => e.action.contains('longPress')),
        isTrue,
      );
    });
  });
}
