import 'package:flutter_test/flutter_test.dart';

import 'metrics_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('MetricsDemoScreen - Counter Demo', () {
    testWidgets('displays Increment button', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      expect(find.text('Increment'), findsOneWidget);
    });

    testWidgets('shows initial count of 0', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('count increments on tap', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('count increments multiple times (3 taps)', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays Reset Display button', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      expect(find.text('Reset Display'), findsOneWidget);
    });

    testWidgets('reset clears count to 0', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      // Increment a few times
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Reset
      await tester.tap(find.text('Reset Display'));
      await tester.pump();

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('count resumes from 0 after reset', (tester) async {
      await tester.pumpWidget(buildMetricsTestWidget());

      // Increment, reset, then increment again
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment'));
      await tester.pump();

      await tester.tap(find.text('Reset Display'));
      await tester.pump();

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });
}
