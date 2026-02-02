import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'metrics_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('MetricsDemoScreen - Counter with Attributes Demo', () {
    Future<void> scrollToAttributesSection(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('Record Action'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('displays Record Action button', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToAttributesSection(tester);

      expect(find.text('Record Action'), findsOneWidget);
    });

    testWidgets('displays category selector with all 4 options',
        (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToAttributesSection(tester);

      expect(find.text('purchase'), findsOneWidget);
      expect(find.text('view'), findsOneWidget);
      expect(find.text('share'), findsOneWidget);
      expect(find.text('favorite'), findsOneWidget);
    });

    testWidgets('records action and shows category in breakdown',
        (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToAttributesSection(tester);

      await tester.tap(find.text('Record Action'));
      await tester.pump();

      // Should show breakdown with Total
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('records multiple categories independently', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToAttributesSection(tester);

      // Record 'purchase' (default selected)
      await tester.tap(find.text('Record Action'));
      await tester.pump();

      // Select 'view' via the SegmentedButton (find within that widget)
      final viewInSegment = find.descendant(
        of: find.byType(SegmentedButton<String>),
        matching: find.text('view'),
      );
      await tester.ensureVisible(viewInSegment);
      await tester.pumpAndSettle();
      await tester.tap(viewInSegment);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record Action'));
      await tester.pump();

      // Should show Total of 2
      expect(find.text('Total'), findsOneWidget);

      // Find the Text widget showing "2" (the total count)
      expect(find.text('2'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows correct per-category counts', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToAttributesSection(tester);

      // Record purchase 3 times
      await tester.tap(find.text('Record Action'));
      await tester.pump();
      await tester.tap(find.text('Record Action'));
      await tester.pump();
      await tester.tap(find.text('Record Action'));
      await tester.pump();

      // Scroll to make sure we can see the breakdown
      await tester.scrollUntilVisible(
        find.text('Total'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Total should be 3
      final totalText = find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data == '3' && widget.style != null,
      );
      expect(totalText, findsAtLeastNWidgets(1));
    });
  });
}
