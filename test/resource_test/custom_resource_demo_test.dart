import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/resource_demo/custom_resource_demo.dart';

import 'resource_test_helpers.dart';

Widget _buildCustomResourceWidget() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CustomResourceDemo(
          onAttributeAdded: () {},
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('CustomResourceDemo', () {
    testWidgets('displays form fields', (tester) async {
      await tester.pumpWidget(_buildCustomResourceWidget());

      expect(find.text('Attribute Key'), findsOneWidget);
      expect(find.text('Attribute Value'), findsOneWidget);
      expect(find.text('Value Type'), findsOneWidget);
      expect(find.text('Add Attribute'), findsOneWidget);
    });

    testWidgets('displays example suggestion chips', (tester) async {
      await tester.pumpWidget(_buildCustomResourceWidget());

      expect(find.text('team.name'), findsOneWidget);
      expect(find.text('feature.flags'), findsOneWidget);
      expect(find.text('app.version.code'), findsOneWidget);
    });

    testWidgets('displays info note', (tester) async {
      await tester.pumpWidget(_buildCustomResourceWidget());

      expect(
        find.text(
          'Custom resource attributes appear on all telemetry emitted by this application.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('validates empty key', (tester) async {
      await tester.pumpWidget(_buildCustomResourceWidget());

      // Leave fields empty and tap Add
      await tester.tap(find.text('Add Attribute'));
      await tester.pumpAndSettle();

      expect(find.text('Key is required'), findsOneWidget);
    });

    testWidgets('validates invalid key format', (tester) async {
      await tester.pumpWidget(_buildCustomResourceWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Attribute Key'),
        'Invalid-Key',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Attribute Value'),
        'value',
      );
      await tester.tap(find.text('Add Attribute'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Must start with lowercase letter, contain only a-z, 0-9, . or _',
        ),
        findsOneWidget,
      );
    });

    testWidgets('validates empty value', (tester) async {
      await tester.pumpWidget(_buildCustomResourceWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Attribute Key'),
        'valid.key',
      );
      await tester.tap(find.text('Add Attribute'));
      await tester.pumpAndSettle();

      expect(find.text('Value is required'), findsOneWidget);
    });

    testWidgets('adds a string attribute and displays it', (tester) async {
      await tester.pumpWidget(_buildCustomResourceWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Attribute Key'),
        'team.name',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Attribute Value'),
        'platform',
      );
      await tester.tap(find.text('Add Attribute'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Attributes'), findsOneWidget);
      expect(find.text('platform'), findsOneWidget);
    });

    testWidgets('suggestion chip fills key field', (tester) async {
      await tester.pumpWidget(_buildCustomResourceWidget());

      await tester.tap(find.text('team.name'));
      await tester.pumpAndSettle();

      // The key field should now contain 'team.name'
      final keyField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Attribute Key'),
      );
      expect(keyField.controller?.text, 'team.name');
    });
  });
}
