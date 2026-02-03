import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'performance_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetPerformanceTrackers();
  });

  group('Jank Simulation Demo', () {
    testWidgets('displays Cause Jank button', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Cause Jank'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Cause Jank'), findsOneWidget);
    });

    testWidgets('displays Cause Smooth Animation button', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.text('Cause Smooth Animation'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Cause Smooth Animation'), findsOneWidget);
    });

    testWidgets('displays warning label', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.textContaining('Warning'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.textContaining('intentionally blocks the UI thread'),
        findsOneWidget,
      );
    });

    testWidgets('displays slider with default value', (tester) async {
      await tester.pumpWidget(buildPerformanceTestWidget());
      await tester.scrollUntilVisible(
        find.byType(Slider),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('150 ms'), findsOneWidget);
    });
  });
}
