import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'package:embrace_flutter_dartastic/screens/tracing_demo_screen.dart';

/// A no-op span processor for tests to avoid gRPC connection errors.
class _NoOpSpanProcessor implements SpanProcessor {
  @override
  Future<void> onStart(Span span, Context? parentContext) async {}
  @override
  Future<void> onEnd(Span span) async {}
  @override
  Future<void> onNameUpdate(Span span, String newName) async {}
  @override
  Future<void> shutdown() async {}
  @override
  Future<void> forceFlush() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TracingDemoScreen - Single Span Demo', () {
    setUpAll(() async {
      await FlutterOTel.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
        tracerName: 'test',
        detectPlatformResources: false,
        flushTracesInterval: null,
        enableMetrics: false,
        spanProcessor: _NoOpSpanProcessor(),
      );
    });

    Widget buildTestWidget() {
      return const MaterialApp(
        home: TracingDemoScreen(),
      );
    }

    testWidgets('displays Create Span button in Single Span section',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Single Span'), findsOneWidget);
      expect(find.text('Create Span'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows loading state while span is active', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Create Span'), findsNothing);

      // Advance past the max simulated delay (1500ms)
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Create Span'), findsOneWidget);
    });

    testWidgets('button is disabled during loading', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 2));

      final enabledButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(enabledButton.onPressed, isNotNull);
    });

    testWidgets('displays trace ID, span ID, and duration after span creation',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // No span details initially
      expect(find.text('Trace ID:'), findsNothing);
      expect(find.text('Span ID:'), findsNothing);
      expect(find.text('Duration:'), findsNothing);

      await tester.tap(find.text('Create Span'));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Trace ID:'), findsOneWidget);
      expect(find.text('Span ID:'), findsOneWidget);
      expect(find.text('Duration:'), findsOneWidget);
    });

    testWidgets('trace ID is 32 hex characters', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span'));
      await tester.pump(const Duration(seconds: 2));

      final traceIdText = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            RegExp(r'^[0-9a-f]{32}$').hasMatch(widget.data!),
      );
      expect(traceIdText, findsOneWidget);
    });

    testWidgets('span ID is 16 hex characters', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span'));
      await tester.pump(const Duration(seconds: 2));

      final spanIdText = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            RegExp(r'^[0-9a-f]{16}$').hasMatch(widget.data!),
      );
      expect(spanIdText, findsOneWidget);
    });

    testWidgets('duration is displayed in milliseconds', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span'));
      await tester.pump(const Duration(seconds: 2));

      final durationText = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            RegExp(r'^\d+ ms$').hasMatch(widget.data!),
      );
      expect(durationText, findsOneWidget);
    });

    testWidgets('span data persists until next span is created',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Create first span
      await tester.tap(find.text('Create Span'));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Trace ID:'), findsOneWidget);
      expect(find.text('Span ID:'), findsOneWidget);
      expect(find.text('Duration:'), findsOneWidget);

      // Data still visible after waiting
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Trace ID:'), findsOneWidget);
      expect(find.text('Span ID:'), findsOneWidget);
      expect(find.text('Duration:'), findsOneWidget);

      // Create second span — details should still be shown (replaced)
      await tester.tap(find.text('Create Span'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Trace ID:'), findsOneWidget);
      expect(find.text('Span ID:'), findsOneWidget);
      expect(find.text('Duration:'), findsOneWidget);
    });
  });
}
