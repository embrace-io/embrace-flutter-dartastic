import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/context_propagation_demo/async_await_context_demo.dart';

import 'context_propagation_test_helpers.dart';

Widget _buildAsyncAwaitTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: AsyncAwaitContextDemo(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('AsyncAwaitContextDemo', () {
    testWidgets('displays Run Async Chain button', (tester) async {
      await tester.pumpWidget(_buildAsyncAwaitTestWidget());

      expect(find.text('Run Async Chain'), findsOneWidget);
    });

    testWidgets('displays results with trace ID and 3 steps after completion',
        (tester) async {
      await tester.pumpWidget(_buildAsyncAwaitTestWidget());

      await tester.tap(find.text('Run Async Chain'));
      // Advance past 3 x 300ms delays + processing time
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.textContaining('Trace ID:'), findsOneWidget);
      expect(find.text('async_chain'), findsOneWidget);
      expect(find.text('step_1'), findsOneWidget);
      expect(find.text('step_2'), findsOneWidget);
      expect(find.text('step_3'), findsOneWidget);
    });
  });
}
