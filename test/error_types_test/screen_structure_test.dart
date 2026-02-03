import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'error_types_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetErrorLogStore();
  });

  group('ErrorsPage - Structure', () {
    testWidgets('displays screen title', (tester) async {
      await tester.pumpWidget(buildErrorTypesTestWidget());

      expect(find.text('Error Types Demo'), findsOneWidget);
    });

    testWidgets('displays Synchronous Errors section title', (tester) async {
      await tester.pumpWidget(buildErrorTypesTestWidget());

      expect(find.text('Synchronous Errors'), findsOneWidget);
    });

    testWidgets('displays Synchronous Errors description', (tester) async {
      await tester.pumpWidget(buildErrorTypesTestWidget());

      expect(
        find.textContaining('Throw and catch synchronous exceptions'),
        findsOneWidget,
      );
    });

    testWidgets('displays Async Errors section title', (tester) async {
      await tester.pumpWidget(buildErrorTypesTestWidget());
      await tester.scrollUntilVisible(
        find.text('Async Errors'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Async Errors'), findsOneWidget);
    });

    testWidgets('displays Flutter Errors section title', (tester) async {
      await tester.pumpWidget(buildErrorTypesTestWidget());
      await tester.scrollUntilVisible(
        find.text('Flutter Errors'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Flutter Errors'), findsOneWidget);
    });

    testWidgets('displays Error with Context section title', (tester) async {
      await tester.pumpWidget(buildErrorTypesTestWidget());
      await tester.drag(find.byType(ListView).first, const Offset(0, -800));
      await tester.pumpAndSettle();

      // The section title and the button inside share the same text,
      // so just verify at least one is found.
      expect(find.text('Error with Context'), findsWidgets);
    });

    testWidgets('displays Error Log section title', (tester) async {
      await tester.pumpWidget(buildErrorTypesTestWidget());
      await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('Error Log'), findsOneWidget);
    });

    testWidgets('contains a ListView', (tester) async {
      await tester.pumpWidget(buildErrorTypesTestWidget());

      expect(find.byType(ListView), findsWidgets);
    });
  });
}
