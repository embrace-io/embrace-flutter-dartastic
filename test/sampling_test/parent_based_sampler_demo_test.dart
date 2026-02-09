import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/sampling_demo/parent_based_sampler_demo.dart';
import 'package:embrace_flutter_dartastic/screens/sampling_demo/sampler_type.dart';
import 'package:embrace_flutter_dartastic/screens/sampling_demo/sampling_statistics.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'sampling_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  setUp(() {
    SamplingStatistics.instance.reset();
    FlutterOTel.tracerProvider.sampler =
        createSampler(SamplerType.parentBased, ratio: 0.5);
  });

  group('ParentBasedSamplerDemo', () {
    Widget buildWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ParentBasedSamplerDemo(),
          ),
        ),
      );
    }

    testWidgets('renders Parent-Based Sampling title', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Parent-Based Sampling'), findsOneWidget);
    });

    testWidgets('renders Create Sampled Parent button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Sampled Parent'), findsOneWidget);
    });

    testWidgets('renders Create Unsampled Parent button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Unsampled Parent'), findsOneWidget);
    });

    testWidgets('renders info note about parent-based sampling',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('inherits the sampling decision'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Create Sampled Parent shows tree with sampled status',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Sampled Parent'));
      await tester.pumpAndSettle();

      expect(find.text('parent (sampled)'), findsOneWidget);
      expect(find.text('child_1'), findsOneWidget);
      expect(find.text('child_2'), findsOneWidget);
    });

    testWidgets(
        'tapping Create Unsampled Parent shows tree with unsampled status',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Unsampled Parent'));
      await tester.pumpAndSettle();

      expect(find.text('parent (unsampled)'), findsOneWidget);
      expect(find.text('child_1'), findsOneWidget);
      expect(find.text('child_2'), findsOneWidget);
    });

    testWidgets('records spans to statistics when creating sampled parent',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Sampled Parent'));
      await tester.pumpAndSettle();

      // Should have recorded 3 spans (1 parent + 2 children)
      expect(SamplingStatistics.instance.spansCreated, equals(3));
    });
  });
}
