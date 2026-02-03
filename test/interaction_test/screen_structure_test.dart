import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interaction_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetInteractionTrackers();
  });

  group('InteractionDemoScreen - Structure', () {
    testWidgets('displays screen title', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      expect(find.text('Interactions Demo'), findsOneWidget);
    });

    testWidgets('displays Interaction Log section title', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      expect(find.text('Interaction Log'), findsOneWidget);
    });

    testWidgets('displays Interaction Log description', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      expect(
        find.textContaining('Real-time log of all widget interactions'),
        findsOneWidget,
      );
    });

    testWidgets('displays Traced Buttons section title', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      expect(find.text('Traced Buttons'), findsOneWidget);
    });

    testWidgets('displays Traced Buttons description', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      expect(
        find.textContaining('Buttons wrapped with OpenTelemetry tracing'),
        findsOneWidget,
      );
    });

    testWidgets('displays Gesture Tracking section title', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());
      await tester.scrollUntilVisible(
        find.text('Gesture Tracking'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Gesture Tracking'), findsOneWidget);
    });

    testWidgets('displays Form Interaction Tracking section title',
        (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());
      await tester.scrollUntilVisible(
        find.text('Form Interaction Tracking'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // Allow any debounce timers from scroll tracking to complete.
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text('Form Interaction Tracking'), findsOneWidget);
    });

    testWidgets('displays Scroll Tracking section title', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());
      await tester.scrollUntilVisible(
        find.text('Scroll Tracking'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // Allow any debounce timers from scroll tracking to complete.
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text('Scroll Tracking'), findsOneWidget);
    });

    testWidgets('contains a ListView', (tester) async {
      await tester.pumpWidget(buildInteractionTestWidget());

      expect(find.byType(ListView), findsWidgets);
    });
  });
}
