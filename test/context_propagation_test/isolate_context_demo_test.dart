import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/context_propagation_demo/isolate_context_demo.dart';

import 'context_propagation_test_helpers.dart';

Widget _buildIsolateTestWidget() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: IsolateContextDemo(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('IsolateContextDemo', () {
    testWidgets('displays Run in Isolate button', (tester) async {
      await tester.pumpWidget(_buildIsolateTestWidget());

      expect(find.text('Run in Isolate'), findsOneWidget);
    });

    // Note: Isolate execution does not work reliably in the Flutter test
    // environment (fake async / no real isolate spawning), so we only
    // test the UI structure here. Full isolate behavior is verified
    // via manual testing with `flutter run`.
  });
}
