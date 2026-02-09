import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'baggage_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('BaggageDemoScreen', () {
    testWidgets('displays Baggage Demo title in AppBar', (tester) async {
      await tester.pumpWidget(buildBaggageTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Baggage Demo'), findsOneWidget);
    });

    testWidgets('displays intro text about baggage', (tester) async {
      await tester.pumpWidget(buildBaggageTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Baggage is used to propagate key-value pairs'),
        findsOneWidget,
      );
    });

    testWidgets('displays Set & Get Baggage section', (tester) async {
      await tester.pumpWidget(buildBaggageTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Set & Get Baggage'), findsOneWidget);
    });

    testWidgets('displays Baggage Propagation section', (tester) async {
      await tester.pumpWidget(buildBaggageTestWidget());
      await tester.pumpAndSettle();

      // Scroll to find the section
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Baggage Propagation'), findsOneWidget);
    });

    testWidgets('displays Baggage in Spans section', (tester) async {
      await tester.pumpWidget(buildBaggageTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Baggage in Spans'), findsOneWidget);
    });

    testWidgets('displays Baggage Limits section', (tester) async {
      await tester.pumpWidget(buildBaggageTestWidget());
      await tester.pumpAndSettle();

      // Scroll multiple times to ensure the bottom section is visible
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Baggage Limits'), findsOneWidget);
    });

    testWidgets('displays info icon', (tester) async {
      await tester.pumpWidget(buildBaggageTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
