import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/context_propagation_demo/future_then_context_demo.dart';

import 'context_propagation_test_helpers.dart';

Widget _buildFutureThenTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: FutureThenContextDemo(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('FutureThenContextDemo', () {
    testWidgets('displays both pattern buttons', (tester) async {
      await tester.pumpWidget(_buildFutureThenTestWidget());

      expect(find.text('Run Correct Pattern'), findsOneWidget);
      expect(find.text('Run Incorrect Pattern'), findsOneWidget);
    });

    testWidgets('correct pattern shows matching trace IDs', (tester) async {
      await tester.pumpWidget(_buildFutureThenTestWidget());

      await tester.tap(find.text('Run Correct Pattern'));
      // Advance past 3 x 200ms delays + processing time
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.text('All trace IDs match'), findsOneWidget);
      expect(find.text('processA'), findsOneWidget);
      expect(find.text('processB'), findsOneWidget);
      expect(find.text('processC'), findsOneWidget);
    });

    testWidgets('incorrect pattern displays results', (tester) async {
      await tester.pumpWidget(_buildFutureThenTestWidget());

      await tester.tap(find.text('Run Incorrect Pattern'));
      // Advance past 3 x 200ms delays + processing time
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      // Results should be displayed (trace IDs may or may not differ
      // depending on the test environment's zone-based context handling)
      expect(find.text('processA'), findsOneWidget);
      expect(find.text('processB'), findsOneWidget);
      expect(find.text('processC'), findsOneWidget);
    });

    testWidgets('displays explanation text after running either pattern',
        (tester) async {
      await tester.pumpWidget(_buildFutureThenTestWidget());

      await tester.tap(find.text('Run Correct Pattern'));
      // Advance past 3 x 200ms delays + processing time
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(
        find.textContaining('explicit parentSpan'),
        findsOneWidget,
      );
    });
  });
}
