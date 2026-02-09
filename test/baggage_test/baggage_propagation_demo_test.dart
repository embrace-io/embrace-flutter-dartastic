import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/baggage_demo/baggage_propagation_demo.dart';

import 'baggage_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('BaggagePropagationDemo', () {
    Widget buildWidget({Baggage? baggage}) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BaggagePropagationDemo(
              baggage: baggage ?? OTel.baggage(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders Make Request with Baggage button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Make Request with Baggage'), findsOneWidget);
    });

    testWidgets('button is disabled when baggage is empty', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Make Request with Baggage'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('button is enabled when baggage has entries', (tester) async {
      final baggage = OTel.baggage().copyWith('key', 'value');
      await tester.pumpWidget(buildWidget(baggage: baggage));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Make Request with Baggage'),
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

    testWidgets('displays W3C Baggage Header Format section', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('W3C Baggage Header Format'), findsOneWidget);
    });

    testWidgets('displays header format example', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('key1=value1,key2=value2;metadata'),
        findsOneWidget,
      );
    });

    testWidgets('displays explanation text', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Baggage entries are comma-separated'),
        findsOneWidget,
      );
    });
  });
}
