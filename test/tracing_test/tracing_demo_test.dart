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
      expect(find.byType(ElevatedButton), findsNWidgets(6));
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
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 2));

      final enabledButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
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

  group('TracingDemoScreen - Nested Span Demo', () {
    setUpAll(() async {
      // FlutterOTel is already initialized from the previous group's setUpAll
    });

    Widget buildTestWidget() {
      return const MaterialApp(
        home: TracingDemoScreen(),
      );
    }

    testWidgets('displays Create Nested Spans button', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Nested Spans'), findsOneWidget);
      expect(find.text('Create Nested Spans'), findsOneWidget);
    });

    testWidgets('shows loading state while creating nested spans',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Nested Spans'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Create Nested Spans'), findsNothing);

      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Create Nested Spans'), findsOneWidget);
    });

    testWidgets('button is disabled during loading', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Nested Spans'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).at(1),
      );
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 2));

      final enabledButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).at(1),
      );
      expect(enabledButton.onPressed, isNotNull);
    });

    testWidgets('displays parent and child span names after creation',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Nested Spans'));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('demo.parent_operation'), findsOneWidget);
      expect(find.text('demo.child_step_1'), findsOneWidget);
      expect(find.text('demo.child_step_2'), findsOneWidget);
      expect(find.text('demo.child_step_3'), findsOneWidget);
    });

    testWidgets('displays shared trace ID', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Nested Spans'));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Trace ID:'), findsOneWidget);
    });

    testWidgets('displays span IDs for parent and all children',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Nested Spans'));
      await tester.pump(const Duration(seconds: 2));

      final spanIdTexts = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.startsWith('Span ID: '),
      );
      expect(spanIdTexts, findsNWidgets(4));
    });

    testWidgets('displays duration and relative start for each span',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Nested Spans'));
      await tester.pump(const Duration(seconds: 2));

      final durationTexts = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            RegExp(r'^Duration: \d+ ms \| Start: \+\d+ ms$')
                .hasMatch(widget.data!),
      );
      expect(durationTexts, findsNWidgets(4));
    });

    testWidgets('parent span appears before child spans in tree',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Nested Spans'));
      await tester.pump(const Duration(seconds: 2));

      // Collect all span name widgets in tree order
      final spanNames = tester
          .widgetList<Text>(find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.data != null &&
                widget.data!.startsWith('demo.'),
          ))
          .map((t) => t.data!)
          .toList();

      expect(spanNames, [
        'demo.parent_operation',
        'demo.child_step_1',
        'demo.child_step_2',
        'demo.child_step_3',
      ]);
    });

    testWidgets('all span IDs are unique 16-hex-character strings',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Nested Spans'));
      await tester.pump(const Duration(seconds: 2));

      final spanIdWidgets = tester.widgetList<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.startsWith('Span ID: '),
        ),
      );

      final spanIds = spanIdWidgets
          .map((text) => text.data!.replaceFirst('Span ID: ', ''))
          .toList();

      expect(spanIds.length, 4);
      for (final id in spanIds) {
        expect(RegExp(r'^[0-9a-f]{16}$').hasMatch(id), isTrue,
            reason: 'Span ID "$id" should be 16 hex characters');
      }
      expect(spanIds.toSet().length, 4,
          reason: 'All 4 span IDs should be unique');
    });
  });

  group('TracingDemoScreen - Span Events Demo', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        home: TracingDemoScreen(),
      );
    }

    testWidgets('displays Create Span with Events button', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Span Events'), findsOneWidget);
      expect(find.text('Create Span with Events'), findsOneWidget);
    });

    testWidgets('shows loading state while creating span with events',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span with Events'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Create Span with Events'), findsNothing);

      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Create Span with Events'), findsOneWidget);
    });

    testWidgets('button is disabled during loading', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span with Events'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).at(2),
      );
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 1));

      final enabledButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).at(2),
      );
      expect(enabledButton.onPressed, isNotNull);
    });

    testWidgets('displays Trace ID, Span ID, and Duration after creation',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span with Events'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Trace ID:'), findsOneWidget);
      expect(find.text('Span ID:'), findsOneWidget);
      expect(find.text('Duration:'), findsOneWidget);
    });

    testWidgets('displays all 3 event names after creation', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span with Events'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('operation.started'), findsOneWidget);
      expect(find.text('checkpoint.reached'), findsOneWidget);
      expect(find.text('operation.completed'), findsOneWidget);
    });

    testWidgets('events show relative timestamps', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span with Events'));
      await tester.pump(const Duration(seconds: 1));

      final timestampTexts = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            RegExp(r'^\+\d+ms$').hasMatch(widget.data!),
      );
      expect(timestampTexts, findsNWidgets(3));
    });

    testWidgets('checkpoint.reached event displays attribute',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span with Events'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('checkpoint.name: validation'), findsOneWidget);
    });

    testWidgets('events appear in chronological order', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Create Span with Events'));
      await tester.pump(const Duration(seconds: 1));

      final eventNames = tester
          .widgetList<Text>(find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.data != null &&
                (widget.data == 'operation.started' ||
                    widget.data == 'checkpoint.reached' ||
                    widget.data == 'operation.completed'),
          ))
          .map((t) => t.data!)
          .toList();

      expect(eventNames, [
        'operation.started',
        'checkpoint.reached',
        'operation.completed',
      ]);
    });
  });

  group('TracingDemoScreen - Span Status Demo', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        home: TracingDemoScreen(),
      );
    }

    Future<void> scrollToStatusSection(WidgetTester tester) async {
      await tester.ensureVisible(find.text('OK Status'));
      await tester.pumpAndSettle();
    }

    testWidgets('displays three status buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await scrollToStatusSection(tester);

      expect(find.text('Span Status'), findsOneWidget);
      expect(find.text('OK Status'), findsOneWidget);
      expect(find.text('Error Status'), findsOneWidget);
      expect(find.text('Unset Status'), findsOneWidget);
    });

    testWidgets('shows loading state when OK Status tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await scrollToStatusSection(tester);

      await tester.tap(find.text('OK Status'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('OK Status'), findsNothing);

      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('OK Status'), findsOneWidget);
    });

    testWidgets('shows loading state when Error Status tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await scrollToStatusSection(tester);

      await tester.tap(find.text('Error Status'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Error Status'), findsNothing);

      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Error Status'), findsOneWidget);
    });

    testWidgets('OK Status creates span and shows green indicator',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await scrollToStatusSection(tester);

      await tester.tap(find.text('OK Status'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('demo.status_ok'), findsOneWidget);
      expect(find.text('Status: ok'), findsOneWidget);

      final statusIcon = tester.widget<Icon>(find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.circle &&
            widget.color == Colors.green,
      ));
      expect(statusIcon, isNotNull);
    });

    testWidgets(
        'Error Status creates span and shows red indicator with description',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await scrollToStatusSection(tester);

      await tester.tap(find.text('Error Status'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('demo.status_error'), findsOneWidget);
      expect(find.text('Status: error'), findsOneWidget);
      expect(find.text('Simulated error for demo'), findsOneWidget);

      final statusIcon = tester.widget<Icon>(find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.circle &&
            widget.color == Colors.red,
      ));
      expect(statusIcon, isNotNull);
    });

    testWidgets('Unset Status creates span and shows gray indicator',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await scrollToStatusSection(tester);

      await tester.tap(find.text('Unset Status'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('demo.status_unset'), findsOneWidget);
      expect(find.text('Status: unset'), findsOneWidget);

      final statusIcon = tester.widget<Icon>(find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.circle &&
            widget.color == Colors.grey,
      ));
      expect(statusIcon, isNotNull);
    });

    testWidgets('each button creates distinctly named span', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await scrollToStatusSection(tester);

      await tester.tap(find.text('OK Status'));
      await tester.pump(const Duration(seconds: 1));

      await tester.ensureVisible(find.text('Error Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Error Status'));
      await tester.pump(const Duration(seconds: 1));

      await tester.ensureVisible(find.text('Unset Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unset Status'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('demo.status_ok'), findsOneWidget);
      expect(find.text('demo.status_error'), findsOneWidget);
      expect(find.text('demo.status_unset'), findsOneWidget);
    });

    testWidgets('buttons disabled during loading', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await scrollToStatusSection(tester);

      await tester.tap(find.text('OK Status'));
      await tester.pump();

      // Find all 3 status buttons (indices 3, 4, 5 — after the first 3 demo buttons)
      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      // The span status buttons are the last 3
      final statusButtons = buttons.toList().sublist(3);
      for (final button in statusButtons) {
        expect(button.onPressed, isNull,
            reason: 'All status buttons should be disabled during loading');
      }

      await tester.pump(const Duration(seconds: 1));

      final enabledButtons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final enabledStatusButtons = enabledButtons.toList().sublist(3);
      for (final button in enabledStatusButtons) {
        expect(button.onPressed, isNotNull,
            reason:
                'All status buttons should be enabled after loading completes');
      }
    });
  });
}
