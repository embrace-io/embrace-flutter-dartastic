import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'resource_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('ResourceDemoScreen', () {
    testWidgets('displays Resources Demo title in AppBar', (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Resources Demo'), findsOneWidget);
    });

    testWidgets('displays refresh button', (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays copy button', (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('displays Service Resources and Platform Resources sections',
        (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Service Resources'), findsOneWidget);
      expect(find.text('Platform Resources'), findsOneWidget);
    });

    testWidgets('displays SDK Resources section after scrolling',
        (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      // Scroll down to reveal SDK Resources section
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('SDK Resources'), findsOneWidget);
    });

    testWidgets('displays Custom Resources section after scrolling',
        (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      // Scroll down further to reveal Custom Resources section
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(find.text('Custom Resources'), findsOneWidget);
    });

    testWidgets('all four DemoSection widgets are reachable by scrolling',
        (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      // First two are visible without scrolling
      expect(find.text('Service Resources'), findsOneWidget);
      expect(find.text('Platform Resources'), findsOneWidget);

      // Scroll to SDK Resources
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('SDK Resources'), findsOneWidget);

      // Scroll to Custom Resources
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Custom Resources'), findsOneWidget);
    });

    testWidgets('refresh button reloads attributes', (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Screen should still display all sections after refresh
      expect(find.text('Service Resources'), findsOneWidget);
      expect(find.text('Platform Resources'), findsOneWidget);
    });

    testWidgets('copy button shows snackbar', (tester) async {
      await tester.pumpWidget(buildResourceTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(
        find.text('Resource attributes copied to clipboard'),
        findsOneWidget,
      );
    });
  });
}
