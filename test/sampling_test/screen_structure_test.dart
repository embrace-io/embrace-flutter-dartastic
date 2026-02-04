import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/sampling_demo/sampler_type.dart';
import 'package:embrace_flutter_dartastic/screens/sampling_demo/sampling_statistics.dart';

import 'sampling_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    SamplingStatistics.instance.reset();
  });

  group('SamplingDemoScreen', () {
    testWidgets('displays Sampling Demo title in AppBar', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sampling Demo'), findsOneWidget);
    });

    testWidgets('displays Current Sampler section', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Current Sampler'), findsOneWidget);
    });

    testWidgets('displays Sampling Statistics section', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sampling Statistics'), findsOneWidget);
    });

    testWidgets('displays Test Sampling section', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Sampling'), findsOneWidget);
    });

    testWidgets('displays Generate Test Span button', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Generate Test Span'), findsOneWidget);
    });

    testWidgets('displays Reset Statistics button', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reset Statistics'), findsOneWidget);
    });

    testWidgets('displays warning text', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      // Scroll to bottom to ensure warning card is visible
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sampling changes only affect new spans'),
        findsOneWidget,
      );
    });

    testWidgets('displays dropdown with sampler types', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<SamplerType>), findsOneWidget);
    });

    testWidgets('displays info icon in warning card', (tester) async {
      await tester.pumpWidget(buildSamplingTestWidget());
      await tester.pumpAndSettle();

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
