import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/error_types_demo/flutter_error_demo.dart';

import 'error_types_test_helpers.dart';

Widget _buildFlutterErrorTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: FlutterErrorDemo(),
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

  group('FlutterErrorDemo', () {
    testWidgets('displays Safe Mode toggle', (tester) async {
      await tester.pumpWidget(_buildFlutterErrorTestWidget());

      expect(find.text('Safe Mode'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('Safe Mode defaults to on', (tester) async {
      await tester.pumpWidget(_buildFlutterErrorTestWidget());

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('displays Build Error button', (tester) async {
      await tester.pumpWidget(_buildFlutterErrorTestWidget());

      expect(find.text('Build Error'), findsOneWidget);
    });

    testWidgets('displays Overflow Error button', (tester) async {
      await tester.pumpWidget(_buildFlutterErrorTestWidget());

      expect(find.text('Overflow Error'), findsOneWidget);
    });

    testWidgets('displays Assertion Error button', (tester) async {
      await tester.pumpWidget(_buildFlutterErrorTestWidget());

      expect(find.text('Assertion Error'), findsOneWidget);
    });

    testWidgets('displays Null Widget button', (tester) async {
      await tester.pumpWidget(_buildFlutterErrorTestWidget());

      expect(find.text('Null Widget'), findsOneWidget);
    });

    testWidgets('toggling Safe Mode changes switch state', (tester) async {
      await tester.pumpWidget(_buildFlutterErrorTestWidget());

      // Initially on.
      var switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);

      // Toggle off.
      await tester.tap(find.byType(Switch));
      await tester.pump();

      switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });
  });
}
