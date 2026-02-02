import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'metrics_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('MetricsDemoScreen - Screen Structure', () {
    testWidgets('displays all 4 section titles', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      expect(find.text('Counter'), findsOneWidget);
      expect(find.text('Counter with Attributes'), findsOneWidget);

      // Histogram and UpDownCounter may be off-screen; scroll to find them
      await tester.scrollUntilVisible(
        find.text('Histogram'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Histogram'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('UpDownCounter'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('UpDownCounter'), findsOneWidget);
    });

    testWidgets('displays description text for each section', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      expect(
        find.textContaining('monotonically increasing counter'),
        findsOneWidget,
      );
      expect(
        find.textContaining('dimensional attributes'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.textContaining('distribution of values'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('distribution of values'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.textContaining('increments and decrements'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('increments and decrements'),
        findsOneWidget,
      );
    });

    testWidgets('screen has a ListView (scrollable)', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
