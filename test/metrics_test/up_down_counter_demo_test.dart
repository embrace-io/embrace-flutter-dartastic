import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'metrics_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('MetricsDemoScreen - UpDownCounter Demo', () {
    Future<void> scrollToUpDownSection(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('Items in Cart'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('displays scenario label "Items in Cart"', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      expect(find.text('Items in Cart'), findsOneWidget);
    });

    testWidgets('shows initial value of 0', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      // The '0' in the UpDownCounter section. The counter section also
      // has a '0' at the top, so we look for at least one.
      expect(find.text('0'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays all four buttons (+, -, +5, -5)', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      expect(find.text('+'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('-5'), findsOneWidget);
    });

    testWidgets('plus increments by 1', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      await tester.tap(find.text('+'));
      await tester.pump();

      // The UpDownCounter section should now show '1'
      expect(find.text('1'), findsAtLeastNWidgets(1));
    });

    testWidgets('minus decrements by 1', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      await tester.tap(find.text('-'));
      await tester.pump();

      expect(find.text('-1'), findsOneWidget);
    });

    testWidgets('+5 increments by 5', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      await tester.tap(find.text('+5'));
      await tester.pump();

      expect(find.text('5'), findsAtLeastNWidgets(1));
    });

    testWidgets('-5 decrements by 5', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      await tester.tap(find.text('-5'));
      await tester.pump();

      expect(find.text('-5'), findsAtLeastNWidgets(1));
    });

    testWidgets('value can go negative', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      await tester.tap(find.text('-'));
      await tester.pump();
      await tester.tap(find.text('-'));
      await tester.pump();

      expect(find.text('-2'), findsOneWidget);
    });

    testWidgets('green up arrow after increment', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      await tester.tap(find.text('+'));
      await tester.pump();

      final upArrow = find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.arrow_upward &&
            widget.color == Colors.green,
      );
      expect(upArrow, findsOneWidget);
    });

    testWidgets('red down arrow after decrement', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      await tester.tap(find.text('-'));
      await tester.pump();

      final downArrow = find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.arrow_downward &&
            widget.color == Colors.red,
      );
      expect(downArrow, findsOneWidget);
    });

    testWidgets('multiple operations accumulate correctly', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToUpDownSection(tester);

      // +5, +5, -, - => 8
      await tester.tap(find.text('+5'));
      await tester.pump();
      await tester.tap(find.text('+5'));
      await tester.pump();
      await tester.tap(find.text('-'));
      await tester.pump();
      await tester.tap(find.text('-'));
      await tester.pump();

      expect(find.text('8'), findsOneWidget);
    });
  });
}
