import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class TracingDemoScreen extends StatelessWidget {
  const TracingDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tracing Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _DemoSection(
            title: 'Single Span',
            child: _SingleSpanDemo(),
          ),
          SizedBox(height: 16),
          _DemoSection(
            title: 'Nested Spans',
            child: _NestedSpanDemo(),
          ),
          SizedBox(height: 16),
          _DemoSection(
            title: 'Span Events',
            child: _SpanEventsDemo(),
          ),
          SizedBox(height: 16),
          _DemoSection(
            title: 'Span Status',
            child: _SpanStatusDemo(),
          ),
        ],
      ),
    );
  }
}

class _SingleSpanDemo extends StatefulWidget {
  const _SingleSpanDemo();

  @override
  State<_SingleSpanDemo> createState() => _SingleSpanDemoState();
}

class _SingleSpanDemoState extends State<_SingleSpanDemo> {
  bool _isLoading = false;
  String? _traceId;
  String? _spanId;
  int? _durationMs;

  Future<void> _createSpan() async {
    setState(() {
      _isLoading = true;
    });

    final stopwatch = Stopwatch()..start();
    final span = FlutterOTel.tracer.startSpan('demo.single_span');

    span.setStringAttribute('user.name', 'demo_user');
    span.setIntAttribute('item.count', 42);
    span.setBoolAttribute('feature.enabled', true);
    span.setDoubleAttribute('score.value', 98.6);

    final delay = Random().nextInt(1001) + 500;
    await Future.delayed(Duration(milliseconds: delay));

    span.end();
    stopwatch.stop();

    setState(() {
      _isLoading = false;
      _traceId = span.spanContext.traceId.toString();
      _spanId = span.spanContext.spanId.toString();
      _durationMs = stopwatch.elapsedMilliseconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createSpan,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Span'),
          ),
        ),
        if (_traceId != null) ...[
          const SizedBox(height: 16),
          _SpanDetailRow(label: 'Trace ID', value: _traceId!),
          const SizedBox(height: 8),
          _SpanDetailRow(label: 'Span ID', value: _spanId!),
          const SizedBox(height: 8),
          _SpanDetailRow(label: 'Duration', value: '$_durationMs ms'),
        ],
      ],
    );
  }
}

class _SpanInfo {
  const _SpanInfo({
    required this.name,
    required this.traceId,
    required this.spanId,
    required this.durationMs,
    required this.relativeStartMs,
  });

  final String name;
  final String traceId;
  final String spanId;
  final int durationMs;
  final int relativeStartMs;
}

class _EventInfo {
  const _EventInfo({
    required this.name,
    required this.relativeMs,
    required this.attributes,
  });

  final String name;
  final int relativeMs;
  final Map<String, String> attributes;
}

class _NestedSpanDemo extends StatefulWidget {
  const _NestedSpanDemo();

  @override
  State<_NestedSpanDemo> createState() => _NestedSpanDemoState();
}

class _NestedSpanDemoState extends State<_NestedSpanDemo> {
  bool _isLoading = false;
  _SpanInfo? _parentInfo;
  List<_SpanInfo> _childInfos = [];

  Future<void> _createNestedSpans() async {
    setState(() {
      _isLoading = true;
    });

    final parentStopwatch = Stopwatch()..start();
    final parentSpan = FlutterOTel.tracer.startSpan('demo.parent_operation');

    final childInfos = <_SpanInfo>[];

    for (int i = 1; i <= 3; i++) {
      final relativeStart = parentStopwatch.elapsedMilliseconds;
      final childStopwatch = Stopwatch()..start();

      final childSpan = FlutterOTel.tracer.startSpan(
        'demo.child_step_$i',
        parentSpan: parentSpan,
      );

      final delay = Random().nextInt(301) + 200; // 200-500ms
      await Future.delayed(Duration(milliseconds: delay));

      childSpan.end();
      childStopwatch.stop();

      childInfos.add(_SpanInfo(
        name: 'demo.child_step_$i',
        traceId: childSpan.spanContext.traceId.toString(),
        spanId: childSpan.spanContext.spanId.toString(),
        durationMs: childStopwatch.elapsedMilliseconds,
        relativeStartMs: relativeStart,
      ));
    }

    parentSpan.end();
    parentStopwatch.stop();

    setState(() {
      _isLoading = false;
      _parentInfo = _SpanInfo(
        name: 'demo.parent_operation',
        traceId: parentSpan.spanContext.traceId.toString(),
        spanId: parentSpan.spanContext.spanId.toString(),
        durationMs: parentStopwatch.elapsedMilliseconds,
        relativeStartMs: 0,
      );
      _childInfos = childInfos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createNestedSpans,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Nested Spans'),
          ),
        ),
        if (_parentInfo != null) ...[
          const SizedBox(height: 16),
          _SpanDetailRow(label: 'Trace ID', value: _parentInfo!.traceId),
          const SizedBox(height: 12),
          _SpanTreeItem(spanInfo: _parentInfo!, indent: 0),
          ..._childInfos.map(
            (info) => _SpanTreeItem(spanInfo: info, indent: 1),
          ),
        ],
      ],
    );
  }
}

class _SpanEventsDemo extends StatefulWidget {
  const _SpanEventsDemo();

  @override
  State<_SpanEventsDemo> createState() => _SpanEventsDemoState();
}

class _SpanEventsDemoState extends State<_SpanEventsDemo> {
  bool _isLoading = false;
  String? _traceId;
  String? _spanId;
  int? _durationMs;
  List<_EventInfo> _events = [];

  Future<void> _createSpanWithEvents() async {
    setState(() {
      _isLoading = true;
    });

    final stopwatch = Stopwatch()..start();
    final span = FlutterOTel.tracer.startSpan('demo.operation_with_events');

    span.addEventNow('operation.started');
    final startedMs = stopwatch.elapsedMilliseconds;

    await Future.delayed(const Duration(milliseconds: 250));

    span.addEventNow(
      'checkpoint.reached',
      {'checkpoint.name': 'validation'}.toAttributes(),
    );
    final checkpointMs = stopwatch.elapsedMilliseconds;

    await Future.delayed(const Duration(milliseconds: 250));

    span.addEventNow('operation.completed');
    final completedMs = stopwatch.elapsedMilliseconds;

    span.end();
    stopwatch.stop();

    setState(() {
      _isLoading = false;
      _traceId = span.spanContext.traceId.toString();
      _spanId = span.spanContext.spanId.toString();
      _durationMs = stopwatch.elapsedMilliseconds;
      _events = [
        _EventInfo(
          name: 'operation.started',
          relativeMs: startedMs,
          attributes: {},
        ),
        _EventInfo(
          name: 'checkpoint.reached',
          relativeMs: checkpointMs,
          attributes: {'checkpoint.name': 'validation'},
        ),
        _EventInfo(
          name: 'operation.completed',
          relativeMs: completedMs,
          attributes: {},
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createSpanWithEvents,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Span with Events'),
          ),
        ),
        if (_traceId != null) ...[
          const SizedBox(height: 16),
          _SpanDetailRow(label: 'Trace ID', value: _traceId!),
          const SizedBox(height: 8),
          _SpanDetailRow(label: 'Span ID', value: _spanId!),
          const SizedBox(height: 8),
          _SpanDetailRow(label: 'Duration', value: '$_durationMs ms'),
          const SizedBox(height: 12),
          ..._events.map(
            (event) => _EventTimelineItem(event: event),
          ),
        ],
      ],
    );
  }
}

class _EventTimelineItem extends StatelessWidget {
  const _EventTimelineItem({required this.event});

  final _EventInfo event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 3, color: colorScheme.tertiary),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '+${event.relativeMs}ms',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              if (event.attributes.isNotEmpty)
                ...event.attributes.entries.map(
                  (entry) => Text(
                    '${entry.key}: ${entry.value}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusResult {
  const _StatusResult({
    required this.spanName,
    required this.traceId,
    required this.spanId,
    required this.statusCode,
    this.description,
  });

  final String spanName;
  final String traceId;
  final String spanId;
  final String statusCode;
  final String? description;
}

class _SpanStatusDemo extends StatefulWidget {
  const _SpanStatusDemo();

  @override
  State<_SpanStatusDemo> createState() => _SpanStatusDemoState();
}

class _SpanStatusDemoState extends State<_SpanStatusDemo> {
  String? _activeButton;
  final List<_StatusResult> _results = [];

  bool get _isLoading => _activeButton != null;

  Future<void> _createSpanWithStatus(
    String spanName,
    SpanStatusCode statusCode, {
    String? description,
  }) async {
    setState(() {
      _activeButton = spanName;
    });

    final span = FlutterOTel.tracer.startSpan(spanName);

    await Future.delayed(const Duration(milliseconds: 300));

    span.setStatus(statusCode, description);
    span.end();

    setState(() {
      _activeButton = null;
      _results.add(_StatusResult(
        spanName: spanName,
        traceId: span.spanContext.traceId.toString(),
        spanId: span.spanContext.spanId.toString(),
        statusCode: statusCode.name.toLowerCase(),
        description: description,
      ));
    });
  }

  Widget _buildButton({
    required String label,
    required String spanName,
    required SpanStatusCode statusCode,
    String? description,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () => _createSpanWithStatus(
                  spanName,
                  statusCode,
                  description: description,
                ),
        child: _activeButton == spanName
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildButton(
          label: 'OK Status',
          spanName: 'demo.status_ok',
          statusCode: SpanStatusCode.Ok,
        ),
        const SizedBox(height: 8),
        _buildButton(
          label: 'Error Status',
          spanName: 'demo.status_error',
          statusCode: SpanStatusCode.Error,
          description: 'Simulated error for demo',
        ),
        const SizedBox(height: 8),
        _buildButton(
          label: 'Unset Status',
          spanName: 'demo.status_unset',
          statusCode: SpanStatusCode.Unset,
        ),
        ..._results.map((result) => _StatusResultItem(result: result)),
      ],
    );
  }
}

class _StatusResultItem extends StatelessWidget {
  const _StatusResultItem({required this.result});

  final _StatusResult result;

  Color _statusColor() {
    switch (result.statusCode) {
      case 'ok':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.spanName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: _statusColor()),
              const SizedBox(width: 6),
              Text(
                'Status: ${result.statusCode}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _statusColor(),
                    ),
              ),
            ],
          ),
          if (result.description != null) ...[
            const SizedBox(height: 2),
            Text(
              result.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Trace ID: ${result.traceId}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          Text(
            'Span ID: ${result.spanId}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }
}

class _SpanTreeItem extends StatelessWidget {
  const _SpanTreeItem({
    required this.spanInfo,
    required this.indent,
  });

  final _SpanInfo spanInfo;
  final int indent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor =
        indent == 0 ? colorScheme.primary : colorScheme.secondary;

    return Padding(
      padding: EdgeInsets.only(left: indent * 24.0, top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(width: 3, color: borderColor)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                spanInfo.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Span ID: ${spanInfo.spanId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              Text(
                'Duration: ${spanInfo.durationMs} ms | Start: +${spanInfo.relativeStartMs} ms',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpanDetailRow extends StatelessWidget {
  const _SpanDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ),
      ],
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
