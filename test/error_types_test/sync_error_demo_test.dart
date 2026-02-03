import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/error_types_demo/error_log_store.dart';
import 'package:embrace_flutter_dartastic/screens/error_types_demo/sync_error_demo.dart';

import 'error_types_test_helpers.dart';

Widget _buildSyncErrorTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SyncErrorDemo(),
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

  group('SyncErrorDemo', () {
    testWidgets('displays Throw Exception button', (tester) async {
      await tester.pumpWidget(_buildSyncErrorTestWidget());

      expect(find.text('Throw Exception'), findsOneWidget);
    });

    testWidgets('displays Throw FormatException button', (tester) async {
      await tester.pumpWidget(_buildSyncErrorTestWidget());

      expect(find.text('Throw FormatException'), findsOneWidget);
    });

    testWidgets('displays Throw Custom Exception button', (tester) async {
      await tester.pumpWidget(_buildSyncErrorTestWidget());

      expect(find.text('Throw Custom Exception'), findsOneWidget);
    });

    testWidgets('displays Throw StateError button', (tester) async {
      await tester.pumpWidget(_buildSyncErrorTestWidget());

      expect(find.text('Throw StateError'), findsOneWidget);
    });

    testWidgets('tapping Throw Exception adds entry to ErrorLogStore',
        (tester) async {
      await tester.pumpWidget(_buildSyncErrorTestWidget());

      await tester.tap(find.text('Throw Exception'));
      await tester.pump();

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'sync');
      expect(entries.first.errorType, 'Exception');
    });

    testWidgets('tapping Throw FormatException adds entry to ErrorLogStore',
        (tester) async {
      await tester.pumpWidget(_buildSyncErrorTestWidget());

      await tester.tap(find.text('Throw FormatException'));
      await tester.pump();

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'sync');
      expect(entries.first.errorType, 'FormatException');
    });

    testWidgets('tapping Throw Custom Exception adds entry to ErrorLogStore',
        (tester) async {
      await tester.pumpWidget(_buildSyncErrorTestWidget());

      await tester.tap(find.text('Throw Custom Exception'));
      await tester.pump();

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'sync');
      expect(entries.first.errorType, 'DemoException');
    });

    testWidgets('tapping Throw StateError adds entry to ErrorLogStore',
        (tester) async {
      await tester.pumpWidget(_buildSyncErrorTestWidget());

      await tester.tap(find.text('Throw StateError'));
      await tester.pump();

      final entries = ErrorLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.source, 'sync');
      expect(entries.first.errorType, 'StateError');
    });
  });
}
