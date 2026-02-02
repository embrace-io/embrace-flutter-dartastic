import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'lifecycle_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('LifecycleObserverDemo', () {
    testWidgets('displays initial state as resumed', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Current State: resumed'), findsOneWidget);
    });

    testWidgets('shows empty state message initially', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('No transitions recorded yet'), findsOneWidget);
    });

    testWidgets('displays Clear Log button', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Clear Log'), findsOneWidget);
    });

    testWidgets('records transition on lifecycle change', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      expect(find.text('Current State: inactive'), findsOneWidget);
      expect(find.textContaining('resumed → inactive'), findsOneWidget);
      expect(find.text('No transitions recorded yet'), findsNothing);
    });

    testWidgets('transition shows previous state as resumed', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      expect(find.textContaining('resumed →'), findsOneWidget);
    });

    testWidgets('transition shows new state correctly', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      expect(find.textContaining('→ inactive'), findsOneWidget);
    });

    testWidgets('Clear Log resets the transitions list', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.textContaining('resumed → inactive'), findsOneWidget);

      await tester.tap(find.text('Clear Log'));
      await tester.pump();

      expect(find.textContaining('resumed → inactive'), findsNothing);
      expect(find.text('No transitions recorded yet'), findsOneWidget);
    });
  });
}
