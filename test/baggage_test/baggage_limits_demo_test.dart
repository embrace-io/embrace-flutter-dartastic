import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/baggage_demo/baggage_limits_demo.dart';

import 'baggage_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('BaggageLimitsDemo', () {
    Widget buildWidget({
      Baggage? baggage,
      ValueChanged<Baggage>? onBaggageChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BaggageLimitsDemo(
              baggage: baggage ?? OTel.baggage(),
              onBaggageChanged: onBaggageChanged ?? (_) {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders entry count display', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Entry Count'), findsOneWidget);
      expect(find.text('0 / 180'), findsOneWidget);
    });

    testWidgets('renders total size display', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Size'), findsOneWidget);
      expect(find.text('0 / 8192 bytes'), findsOneWidget);
    });

    testWidgets('renders progress indicators', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('renders Add Large Value button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Large Value'), findsOneWidget);
    });

    testWidgets('renders Add Many Entries button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Many Entries'), findsOneWidget);
    });

    testWidgets('displays W3C Baggage Limits section', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('W3C Baggage Limits'), findsOneWidget);
      expect(find.textContaining('Max entries: 180'), findsOneWidget);
      expect(find.textContaining('Max total size: 8192 bytes'), findsOneWidget);
    });

    testWidgets('displays Best Practices section', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Best Practices'), findsOneWidget);
      expect(
        find.textContaining('Keep baggage entries small and essential'),
        findsOneWidget,
      );
    });

    testWidgets('updates counts when baggage has entries', (tester) async {
      final baggage = OTel.baggage().copyWith('key1', 'value1');
      await tester.pumpWidget(buildWidget(baggage: baggage));
      await tester.pumpAndSettle();

      expect(find.text('1 / 180'), findsOneWidget);
    });

    testWidgets('calls onBaggageChanged when adding large value',
        (tester) async {
      Baggage? updatedBaggage;
      await tester.pumpWidget(
        buildWidget(onBaggageChanged: (b) => updatedBaggage = b),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Large Value'));
      await tester.pumpAndSettle();

      expect(updatedBaggage, isNotNull);
      expect(updatedBaggage!.getValue('large_value'), isNotNull);
    });

    testWidgets('calls onBaggageChanged when adding many entries',
        (tester) async {
      Baggage? updatedBaggage;
      await tester.pumpWidget(
        buildWidget(onBaggageChanged: (b) => updatedBaggage = b),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Many Entries'));
      await tester.pumpAndSettle();

      expect(updatedBaggage, isNotNull);
      expect(updatedBaggage!.getAllEntries().length, greaterThanOrEqualTo(100));
    });

    testWidgets('shows result message after adding large value',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Large Value'));
      await tester.pumpAndSettle();

      expect(find.textContaining('5120-byte value'), findsOneWidget);
    });

    testWidgets('shows result message after adding many entries',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Many Entries'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Added 100 entries'), findsOneWidget);
    });
  });
}
