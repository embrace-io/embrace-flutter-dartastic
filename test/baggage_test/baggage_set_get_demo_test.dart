import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/baggage_demo/baggage_set_get_demo.dart';

import 'baggage_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('BaggageSetGetDemo', () {
    Widget buildWidget({
      Baggage? baggage,
      ValueChanged<Baggage>? onBaggageChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BaggageSetGetDemo(
              baggage: baggage ?? OTel.baggage(),
              onBaggageChanged: onBaggageChanged ?? (_) {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders key, value, and metadata text fields', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Key'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
      expect(find.text('Metadata (optional)'), findsOneWidget);
    });

    testWidgets('renders Set Baggage button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Set Baggage'), findsOneWidget);
    });

    testWidgets('renders Clear All button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('renders Get Value button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Get Value'), findsOneWidget);
    });

    testWidgets('displays empty state message when no entries', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('No baggage entries set.'), findsOneWidget);
    });

    testWidgets('shows validation error when key or value is empty',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Set Baggage'));
      await tester.pumpAndSettle();

      expect(find.text('Key and value are required.'), findsOneWidget);
    });

    testWidgets('calls onBaggageChanged when setting baggage', (tester) async {
      Baggage? updatedBaggage;
      await tester.pumpWidget(
        buildWidget(onBaggageChanged: (b) => updatedBaggage = b),
      );
      await tester.pumpAndSettle();

      // Enter key and value
      await tester.enterText(
        find.widgetWithText(TextField, 'Key'),
        'test_key',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Value'),
        'test_value',
      );
      await tester.tap(find.text('Set Baggage'));
      await tester.pumpAndSettle();

      expect(updatedBaggage, isNotNull);
      expect(updatedBaggage!.getValue('test_key'), equals('test_value'));
    });

    testWidgets('displays existing baggage entries', (tester) async {
      final baggage = OTel.baggage().copyWith('my_key', 'my_value');
      await tester.pumpWidget(buildWidget(baggage: baggage));
      await tester.pumpAndSettle();

      expect(find.textContaining('my_key = my_value'), findsOneWidget);
    });

    testWidgets('calls onBaggageChanged when removing entry', (tester) async {
      Baggage? updatedBaggage;
      final baggage = OTel.baggage().copyWith('remove_me', 'value');
      await tester.pumpWidget(
        buildWidget(
          baggage: baggage,
          onBaggageChanged: (b) => updatedBaggage = b,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(updatedBaggage, isNotNull);
      expect(updatedBaggage!.isEmpty, isTrue);
    });

    testWidgets('calls onBaggageChanged when clearing all', (tester) async {
      Baggage? updatedBaggage;
      final baggage = OTel.baggage().copyWith('k1', 'v1').copyWith('k2', 'v2');
      await tester.pumpWidget(
        buildWidget(
          baggage: baggage,
          onBaggageChanged: (b) => updatedBaggage = b,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(updatedBaggage, isNotNull);
      expect(updatedBaggage!.isEmpty, isTrue);
    });

    testWidgets('get value shows result for existing key', (tester) async {
      final baggage = OTel.baggage().copyWith('lookup_key', 'found_value');
      await tester.pumpWidget(buildWidget(baggage: baggage));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Key to look up'),
        'lookup_key',
      );
      await tester.tap(find.text('Get Value'));
      await tester.pumpAndSettle();

      expect(find.text('Result: found_value'), findsOneWidget);
    });

    testWidgets('get value shows not found for missing key', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Key to look up'),
        'missing_key',
      );
      await tester.tap(find.text('Get Value'));
      await tester.pumpAndSettle();

      expect(find.text('Result: Not found'), findsOneWidget);
    });
  });
}
