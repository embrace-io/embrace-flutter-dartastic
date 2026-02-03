import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/interaction_demo/form_interaction_demo.dart';
import 'package:embrace_flutter_dartastic/screens/interaction_demo/interaction_log_store.dart';

import 'interaction_test_helpers.dart';

/// Builds the form demo in isolation so the Submit button is on-screen.
Widget _buildFormTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: FormInteractionDemo(),
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
    resetInteractionTrackers();
  });

  group('FormInteractionDemo', () {
    testWidgets('displays Name field', (tester) async {
      await tester.pumpWidget(_buildFormTestWidget());

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('displays Email field', (tester) async {
      await tester.pumpWidget(_buildFormTestWidget());

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('displays Age field', (tester) async {
      await tester.pumpWidget(_buildFormTestWidget());

      expect(find.text('Age'), findsOneWidget);
    });

    testWidgets('displays Submit button', (tester) async {
      await tester.pumpWidget(_buildFormTestWidget());

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(_buildFormTestWidget());

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Age is required'), findsOneWidget);
    });

    testWidgets('logs interaction on submit', (tester) async {
      await tester.pumpWidget(_buildFormTestWidget());

      await tester.tap(find.text('Submit'));
      await tester.pump();

      final entries = InteractionLogStore.instance.entries;
      expect(entries.any((e) => e.widgetType == 'Form'), isTrue);
    });

    testWidgets('shows email validation error for invalid email',
        (tester) async {
      await tester.pumpWidget(_buildFormTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'notanemail',
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });
  });
}
