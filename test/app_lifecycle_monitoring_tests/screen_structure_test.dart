import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'lifecycle_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('LifecycleDemoScreen - Structure', () {
    testWidgets('displays screen title', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Lifecycle Demo'), findsOneWidget);
    });

    testWidgets('displays Lifecycle Observer section title', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Lifecycle Observer'), findsOneWidget);
    });

    testWidgets('displays Launch Tracking section title', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Launch Tracking'), findsOneWidget);
    });

    testWidgets('contains a ListView', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays Lifecycle Observer description', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(
        find.textContaining('Monitors app lifecycle state changes'),
        findsOneWidget,
      );
    });

    testWidgets('displays Launch Tracking description', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(
        find.textContaining('Measures cold start time'),
        findsOneWidget,
      );
    });

    testWidgets('displays Lifecycle Metrics section title', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await tester.scrollUntilVisible(
        find.text('Lifecycle Metrics'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Lifecycle Metrics'), findsOneWidget);
    });

    testWidgets('displays Lifecycle Metrics description', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await tester.scrollUntilVisible(
        find.textContaining('Aggregated OTel metrics'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.textContaining('Aggregated OTel metrics'),
        findsOneWidget,
      );
    });
  });
}
