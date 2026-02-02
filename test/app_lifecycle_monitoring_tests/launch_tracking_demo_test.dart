import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/lifecycle_demo/launch_tracker.dart';

import 'lifecycle_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('LaunchTrackingDemo - UI', () {
    testWidgets('displays Launch Tracking section title', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Launch Tracking'), findsOneWidget);
    });

    testWidgets('shows measuring state before cold start recorded',
        (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Cold Start: measuring...'), findsOneWidget);
    });

    testWidgets('shows cold start duration after recording', (tester) async {
      final tracker = LaunchTracker.instance;
      tracker.recordMainStart(DateTime.now());
      tracker.initialize();

      await tester.pumpWidget(buildLifecycleTestWidget());
      await tester.pump();

      expect(find.textContaining('Cold Start:'), findsOneWidget);
      expect(find.textContaining('ms'), findsWidgets);
      expect(find.text('Cold Start: measuring...'), findsNothing);
    });

    testWidgets('shows Warm Starts heading', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(find.text('Warm Starts'), findsOneWidget);
    });

    testWidgets('shows empty warm starts message initially', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(
        find.textContaining('No warm starts recorded yet'),
        findsOneWidget,
      );
    });

    testWidgets('displays warm start entry after recording', (tester) async {
      final tracker = LaunchTracker.instance;
      tracker.recordMainStart(DateTime.now());
      tracker.initialize();

      await tester.pumpWidget(buildLifecycleTestWidget());
      await tester.pump();

      // Simulate background → foreground
      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();

      expect(find.textContaining('No warm starts recorded yet'), findsNothing);
      // Should show the warm start duration in ms
      expect(find.textContaining('ms'), findsWidgets);
    });

    testWidgets('displays section description', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());

      expect(
        find.textContaining('Measures cold start time'),
        findsOneWidget,
      );
    });
  });
}
