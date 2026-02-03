import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/error_types_demo/async_error_demo.dart';
import 'package:embrace_flutter_dartastic/screens/error_types_demo/error_log_store.dart';

import 'error_types_test_helpers.dart';

Widget _buildAsyncErrorTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: AsyncErrorDemo(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetErrorLogStore();
  });

  group('AsyncErrorDemo', () {
    testWidgets('displays Future.error button', (tester) async {
      await tester.pumpWidget(_buildAsyncErrorTestWidget());

      expect(find.text('Future.error'), findsOneWidget);
    });

    testWidgets('displays Async Exception button', (tester) async {
      await tester.pumpWidget(_buildAsyncErrorTestWidget());

      expect(find.text('Async Exception'), findsOneWidget);
    });

    testWidgets('displays Stream Error button', (tester) async {
      await tester.pumpWidget(_buildAsyncErrorTestWidget());

      expect(find.text('Stream Error'), findsOneWidget);
    });

    testWidgets('displays Uncaught Async button', (tester) async {
      await tester.pumpWidget(_buildAsyncErrorTestWidget());

      expect(find.text('Uncaught Async'), findsOneWidget);
    });

    testWidgets('tapping Future.error adds entry with async source',
        (tester) async {
      await tester.pumpWidget(_buildAsyncErrorTestWidget());

      await tester.tap(find.text('Future.error'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'async');
      expect(entries.first.errorType, 'Future.error');
    });

    testWidgets('tapping Async Exception adds entry with async source',
        (tester) async {
      await tester.pumpWidget(_buildAsyncErrorTestWidget());

      await tester.tap(find.text('Async Exception'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'async');
      expect(entries.first.errorType, 'Async Exception');
    });

    testWidgets('tapping Stream Error adds entry with async source',
        (tester) async {
      await tester.pumpWidget(_buildAsyncErrorTestWidget());

      await tester.tap(find.text('Stream Error'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'async');
      expect(entries.first.errorType, 'Stream.error');
    });

    testWidgets('tapping Uncaught Async adds entry with async source',
        (tester) async {
      await tester.pumpWidget(_buildAsyncErrorTestWidget());

      await tester.tap(find.text('Uncaught Async'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'async');
      expect(entries.first.errorType, 'Uncaught Async');
    });
  });
}
