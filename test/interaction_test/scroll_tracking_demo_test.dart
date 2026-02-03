import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/interaction_demo/scroll_tracking_demo.dart';

import 'interaction_test_helpers.dart';

/// Builds the scroll demo in isolation.
Widget _buildScrollTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ScrollTrackingDemo(),
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

  group('ScrollTrackingDemo', () {
    testWidgets('displays scroll instructions', (tester) async {
      await tester.pumpWidget(_buildScrollTestWidget());

      expect(
        find.text('Scroll the list below to track scroll interactions:'),
        findsOneWidget,
      );
    });

    testWidgets('displays list items', (tester) async {
      await tester.pumpWidget(_buildScrollTestWidget());

      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}
