import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/error_types_demo/error_log_store.dart';
import 'package:embrace_flutter_dartastic/screens/error_types_demo/error_with_context_demo.dart';

import 'error_types_test_helpers.dart';

Widget _buildContextTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ErrorWithContextDemo(),
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

  group('ErrorWithContextDemo', () {
    testWidgets('displays User ID field', (tester) async {
      await tester.pumpWidget(_buildContextTestWidget());

      expect(find.text('User ID'), findsOneWidget);
    });

    testWidgets('displays Session ID field', (tester) async {
      await tester.pumpWidget(_buildContextTestWidget());

      expect(find.text('Session ID'), findsOneWidget);
    });

    testWidgets('displays Error with Context button', (tester) async {
      await tester.pumpWidget(_buildContextTestWidget());

      expect(find.text('Error with Context'), findsOneWidget);
    });

    testWidgets('displays privacy note', (tester) async {
      await tester.pumpWidget(_buildContextTestWidget());

      expect(
        find.textContaining('user data should be sanitized'),
        findsOneWidget,
      );
    });

    testWidgets('tapping button adds entry with context source',
        (tester) async {
      await tester.pumpWidget(_buildContextTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'User ID'),
        'test-user',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Session ID'),
        'test-session',
      );
      await tester.pump();

      await tester.tap(find.text('Error with Context'));
      await tester.pump();

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'context');
      expect(entries.first.errorType, 'Context Error');
      expect(entries.first.message, contains('test-user'));
      expect(entries.first.message, contains('test-session'));
    });

    testWidgets('button works with empty fields using defaults',
        (tester) async {
      await tester.pumpWidget(_buildContextTestWidget());

      await tester.tap(find.text('Error with Context'));
      await tester.pump();

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'context');
      expect(entries.first.message, contains('anonymous'));
      expect(entries.first.message, contains('no-session'));
    });
  });
}
