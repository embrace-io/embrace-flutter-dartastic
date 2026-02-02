import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/lifecycle_demo/lifecycle_metrics.dart';

import 'lifecycle_test_helpers.dart';

/// Scrolls the ListView until the Lifecycle Metrics section is visible.
Future<void> _scrollToMetricsSection(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Lifecycle Metrics'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    resetLifecycleStore();
  });

  group('LifecycleMetricsDemo - UI', () {
    testWidgets('displays section title', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      expect(find.text('Lifecycle Metrics'), findsOneWidget);
    });

    testWidgets('displays section description', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      expect(
        find.textContaining('Aggregated OTel metrics'),
        findsOneWidget,
      );
    });

    testWidgets('shows Total Transitions label', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      expect(find.text('Total Transitions'), findsOneWidget);
    });

    testWidgets('shows Longest Foreground label', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      expect(find.text('Longest Foreground'), findsOneWidget);
    });

    testWidgets('shows Longest Background label', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      expect(find.text('Longest Background'), findsOneWidget);
    });

    testWidgets('shows Session Duration label', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      expect(find.text('Session Duration'), findsOneWidget);
    });

    testWidgets('shows zero transitions initially', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('updates after recording a transition', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      LifecycleMetrics.instance.recordTransition('resumed', 'inactive');
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('updates longest foreground after recording', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      LifecycleMetrics.instance.recordForegroundSession(1500);
      await tester.pump();

      expect(find.text('1.5s'), findsOneWidget);
    });

    testWidgets('updates longest background after recording', (tester) async {
      await tester.pumpWidget(buildLifecycleTestWidget());
      await _scrollToMetricsSection(tester);

      LifecycleMetrics.instance.recordBackgroundDuration(2500);
      await tester.pump();

      expect(find.text('2.5s'), findsOneWidget);
    });
  });
}
