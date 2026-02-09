import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/baggage_demo/baggage_in_spans_demo.dart';

import 'baggage_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('BaggageInSpansDemo', () {
    Widget buildWidget({Baggage? baggage}) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BaggageInSpansDemo(
              baggage: baggage ?? OTel.baggage(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders Create Span with Baggage button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Span with Baggage'), findsOneWidget);
    });

    testWidgets('button is disabled when baggage is empty', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create Span with Baggage'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('button is enabled when baggage has entries', (tester) async {
      final baggage = OTel.baggage().copyWith('key', 'value');
      await tester.pumpWidget(buildWidget(baggage: baggage));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create Span with Baggage'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows hint when baggage is empty', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Add baggage entries above first.'),
        findsOneWidget,
      );
    });

    testWidgets('displays span details after creating span', (tester) async {
      final baggage = OTel.baggage().copyWith('user_id', 'abc123');
      await tester.pumpWidget(buildWidget(baggage: baggage));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Span with Baggage'));
      await tester.pumpAndSettle();

      expect(find.text('Span Details'), findsOneWidget);
      expect(find.textContaining('Name: baggage.demo_span'), findsOneWidget);
      expect(find.textContaining('Trace ID:'), findsOneWidget);
      expect(find.textContaining('Span ID:'), findsOneWidget);
    });

    testWidgets('displays baggage attributes after creating span',
        (tester) async {
      final baggage = OTel.baggage().copyWith('user_id', 'abc123');
      await tester.pumpWidget(buildWidget(baggage: baggage));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Span with Baggage'));
      await tester.pumpAndSettle();

      expect(find.text('Baggage Attributes'), findsOneWidget);
      expect(
        find.text('baggage.user_id = abc123'),
        findsOneWidget,
      );
    });

    testWidgets('renders auto-copy toggle', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Auto-copy baggage to all spans'), findsOneWidget);
    });

    testWidgets('displays common patterns section', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Common Patterns'), findsOneWidget);
      expect(find.textContaining('user_id'), findsOneWidget);
      expect(find.textContaining('tenant_id'), findsOneWidget);
      expect(find.textContaining('request_id'), findsOneWidget);
    });

    testWidgets('displays usage guidance text', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Use baggage for cross-service context'),
        findsOneWidget,
      );
    });
  });
}
