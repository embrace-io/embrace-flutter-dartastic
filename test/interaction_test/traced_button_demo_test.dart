import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/interaction_demo/interaction_log_store.dart';
import 'package:embrace_flutter_dartastic/screens/interaction_demo/traced_button_demo.dart';

import 'interaction_test_helpers.dart';

/// Builds the button demo in isolation so all buttons are on-screen.
Widget _buildButtonTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: TracedButtonDemo(),
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

  group('TracedButtonDemo', () {
    testWidgets('displays ElevatedButton', (tester) async {
      await tester.pumpWidget(_buildButtonTestWidget());

      expect(find.text('ElevatedButton'), findsOneWidget);
    });

    testWidgets('displays TextButton', (tester) async {
      await tester.pumpWidget(_buildButtonTestWidget());

      expect(find.text('TextButton'), findsOneWidget);
    });

    testWidgets('displays IconButton', (tester) async {
      await tester.pumpWidget(_buildButtonTestWidget());

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('displays disabled button', (tester) async {
      await tester.pumpWidget(_buildButtonTestWidget());

      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('tap on ElevatedButton records interaction in log store',
        (tester) async {
      await tester.pumpWidget(_buildButtonTestWidget());

      await tester.tap(find.text('ElevatedButton'));
      await tester.pump();

      final entries = InteractionLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.widgetType, 'Button');
      expect(entries.first.action, 'tap: elevated');
    });

    testWidgets('tap on TextButton records interaction in log store',
        (tester) async {
      await tester.pumpWidget(_buildButtonTestWidget());

      await tester.tap(find.text('TextButton'));
      await tester.pump();

      final entries = InteractionLogStore.instance.entries;
      expect(entries.length, 1);
      expect(entries.first.action, 'tap: text');
    });

    testWidgets('updates last tapped display on tap', (tester) async {
      await tester.pumpWidget(_buildButtonTestWidget());

      expect(find.text('Last tapped: None'), findsOneWidget);

      await tester.tap(find.text('ElevatedButton'));
      await tester.pump();

      expect(find.text('Last tapped: ElevatedButton'), findsOneWidget);
    });
  });
}
