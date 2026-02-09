import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/sampling_demo/rate_limiting_sampler_demo.dart';
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
        createSampler(SamplerType.rateLimiting, spansPerSecond: 10.0);
  });

  group('RateLimitingSamplerDemo', () {
    Widget buildWidget({
      double spansPerSecond = 10.0,
      ValueChanged<double>? onRateChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RateLimitingSamplerDemo(
              spansPerSecond: spansPerSecond,
              onRateChanged: onRateChanged ?? (_) {},
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

    testWidgets('displays rate limit label', (tester) async {
      await tester.pumpWidget(buildWidget(spansPerSecond: 10.0));
      await tester.pumpAndSettle();

      expect(find.text('Rate Limit: 10 spans/sec'), findsOneWidget);
    });

    testWidgets('renders Burst 50 Spans button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Burst 50 Spans'), findsOneWidget);
    });

    testWidgets('renders info note about token bucket', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('token bucket'),
        findsOneWidget,
      );
    });

    testWidgets('slider calls onRateChanged', (tester) async {
      double? changedRate;
      await tester.pumpWidget(
        buildWidget(onRateChanged: (r) => changedRate = r),
      );
      await tester.pumpAndSettle();

      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(changedRate, isNotNull);
    });

    testWidgets('tapping Burst 50 Spans shows results', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Burst 50 Spans'));
      await tester.pumpAndSettle();

      expect(find.textContaining('sampled'), findsWidgets);
      expect(find.textContaining('dropped'), findsWidgets);
    });

    testWidgets('updates rate label when spansPerSecond changes',
        (tester) async {
      await tester.pumpWidget(buildWidget(spansPerSecond: 25.0));
      await tester.pumpAndSettle();

      expect(find.text('Rate Limit: 25 spans/sec'), findsOneWidget);
    });
  });
}
