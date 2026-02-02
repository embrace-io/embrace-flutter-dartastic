import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'metrics_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('MetricsDemoScreen - Histogram Demo', () {
    Future<void> scrollToHistogramSection(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('Record Random'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('displays three record buttons', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToHistogramSection(tester);

      expect(find.text('Record Random'), findsOneWidget);
      expect(find.text('Record Fast'), findsOneWidget);
      expect(find.text('Record Slow'), findsOneWidget);
    });

    testWidgets('no stats displayed initially', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToHistogramSection(tester);

      expect(find.text('Count:'), findsNothing);
      expect(find.text('Min:'), findsNothing);
      expect(find.text('Max:'), findsNothing);
      expect(find.text('Average:'), findsNothing);
    });

    testWidgets('recording shows stats (Count, Min, Max, Average)',
        (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToHistogramSection(tester);

      await tester.tap(find.text('Record Random'));
      await tester.pump();

      // Scroll down to see stats
      await tester.scrollUntilVisible(
        find.text('Count:'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Count:'), findsOneWidget);
      expect(find.text('Min:'), findsOneWidget);
      expect(find.text('Max:'), findsOneWidget);
      expect(find.text('Average:'), findsOneWidget);
    });

    testWidgets('count increments with each recording', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToHistogramSection(tester);

      await tester.tap(find.text('Record Random'));
      await tester.pump();
      await tester.tap(find.text('Record Random'));
      await tester.pump();
      await tester.tap(find.text('Record Random'));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Count:'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Count value should be "3"
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == '3',
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('Record Fast value in 50-200 range', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToHistogramSection(tester);

      await tester.tap(find.text('Record Fast'));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Min:'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Find the min value text (should be between 50 and 200)
      final minValueWidget = find.byWidgetPredicate((widget) {
        if (widget is! Text || widget.data == null) return false;
        final match = RegExp(r'^([\d.]+) ms$').firstMatch(widget.data!);
        if (match == null) return false;
        final value = double.tryParse(match.group(1)!);
        return value != null && value >= 50 && value <= 200;
      });
      expect(minValueWidget, findsAtLeastNWidgets(1));
    });

    testWidgets('Record Slow value in 1000-2000 range', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToHistogramSection(tester);

      await tester.tap(find.text('Record Slow'));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Min:'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Find the min value text (should be between 1000 and 2000)
      final valueWidget = find.byWidgetPredicate((widget) {
        if (widget is! Text || widget.data == null) return false;
        final match = RegExp(r'^([\d.]+) ms$').firstMatch(widget.data!);
        if (match == null) return false;
        final value = double.tryParse(match.group(1)!);
        return value != null && value >= 1000 && value <= 2000;
      });
      expect(valueWidget, findsAtLeastNWidgets(1));
    });

    testWidgets('bucket labels appear after recording', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());
      await scrollToHistogramSection(tester);

      await tester.tap(find.text('Record Random'));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('0-100'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('0-100'), findsOneWidget);
      expect(find.text('100-500'), findsOneWidget);
      expect(find.text('500-1000'), findsOneWidget);
      expect(find.text('1000+'), findsOneWidget);
    });
  });
}
