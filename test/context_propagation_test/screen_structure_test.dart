import 'package:flutter_test/flutter_test.dart';

import 'context_propagation_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('ContextPropagationDemoScreen', () {
    testWidgets('displays screen title', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());

      expect(find.text('Context Propagation Demo'), findsOneWidget);
    });

    testWidgets('displays Current Context section', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());

      expect(find.text('Current Context'), findsOneWidget);
    });

    testWidgets('displays Async/Await Context section', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());

      expect(find.text('Async/Await Context'), findsOneWidget);
    });

    testWidgets('displays Future.then Callbacks section', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());

      expect(find.text('Future.then Callbacks'), findsOneWidget);
    });

    testWidgets('displays Isolate Context section', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());
      await tester.scrollUntilVisible(
        find.text('Isolate Context'),
        200,
      );

      expect(find.text('Isolate Context'), findsOneWidget);
    });

    testWidgets('displays HTTP Context Propagation section', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());
      await tester.scrollUntilVisible(
        find.text('HTTP Context Propagation'),
        200,
      );

      expect(find.text('HTTP Context Propagation'), findsOneWidget);
    });

    testWidgets('displays Run Async Chain button', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());

      expect(find.text('Run Async Chain'), findsOneWidget);
    });

    testWidgets('displays Run Correct Pattern button', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());

      expect(find.text('Run Correct Pattern'), findsOneWidget);
    });

    testWidgets('displays Run Incorrect Pattern button', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());

      expect(find.text('Run Incorrect Pattern'), findsOneWidget);
    });

    testWidgets('displays Run in Isolate button', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());
      await tester.scrollUntilVisible(
        find.text('Run in Isolate'),
        200,
      );

      expect(find.text('Run in Isolate'), findsOneWidget);
    });

    testWidgets('displays Make Traced Request button', (tester) async {
      await tester.pumpWidget(buildContextPropagationTestWidget());
      await tester.scrollUntilVisible(
        find.text('Make Traced Request'),
        200,
      );

      expect(find.text('Make Traced Request'), findsOneWidget);
    });
  });
}
