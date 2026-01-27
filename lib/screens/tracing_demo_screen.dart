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
            child: Placeholder(fallbackHeight: 100),
          ),
          SizedBox(height: 16),
          _DemoSection(
            title: 'Span Events',
            child: Placeholder(fallbackHeight: 100),
          ),
          SizedBox(height: 16),
          _DemoSection(
            title: 'Span Status',
            child: Placeholder(fallbackHeight: 100),
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
