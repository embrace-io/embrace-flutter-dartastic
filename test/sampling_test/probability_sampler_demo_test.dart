import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/sampling_demo/probability_sampler_demo.dart';
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
        createSampler(SamplerType.traceIdRatio, ratio: 0.5);
  });

  group('ProbabilitySamplerDemo', () {
    Widget buildWidget({
      double ratio = 0.5,
      ValueChanged<double>? onRatioChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProbabilitySamplerDemo(
              ratio: ratio,
              onRatioChanged: onRatioChanged ?? (_) {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders slider', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('displays sampling probability label', (tester) async {
      await tester.pumpWidget(buildWidget(ratio: 0.5));
      await tester.pumpAndSettle();

      expect(find.text('Sampling Probability: 50%'), findsOneWidget);
    });

    testWidgets('renders Generate 100 Spans button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Generate 100 Spans'), findsOneWidget);
    });

    testWidgets('renders info note about deterministic sampling',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('deterministic per trace ID'),
        findsOneWidget,
      );
    });

    testWidgets('slider calls onRatioChanged', (tester) async {
      double? changedRatio;
      await tester.pumpWidget(
        buildWidget(onRatioChanged: (r) => changedRatio = r),
      );
      await tester.pumpAndSettle();

      // Drag the slider to a new position
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(changedRatio, isNotNull);
    });

    testWidgets('tapping Generate 100 Spans shows results', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate 100 Spans'));
      await tester.pumpAndSettle();

      expect(find.textContaining('sampled out of 100'), findsOneWidget);
    });

    testWidgets('updates percentage label when ratio changes', (tester) async {
      await tester.pumpWidget(buildWidget(ratio: 0.75));
      await tester.pumpAndSettle();

      expect(find.text('Sampling Probability: 75%'), findsOneWidget);
    });
  });
}
