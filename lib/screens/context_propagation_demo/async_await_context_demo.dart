import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class _StepInfo {
  const _StepInfo({
    required this.name,
    required this.spanId,
    required this.durationMs,
    required this.relativeStartMs,
  });

  final String name;
  final String spanId;
  final int durationMs;
  final int relativeStartMs;
}

class AsyncAwaitContextDemo extends StatefulWidget {
  const AsyncAwaitContextDemo({super.key});

  @override
  State<AsyncAwaitContextDemo> createState() => _AsyncAwaitContextDemoState();
}

class _AsyncAwaitContextDemoState extends State<AsyncAwaitContextDemo> {
  bool _isLoading = false;
  String? _traceId;
  String? _parentSpanId;
  List<_StepInfo> _steps = [];

  Future<void> _runAsyncChain() async {
    setState(() {
      _isLoading = true;
      _traceId = null;
      _parentSpanId = null;
      _steps = [];
    });

    final overallStopwatch = Stopwatch()..start();
    final parentSpan = FlutterOTel.tracer.startSpan('async_chain');

    final steps = <_StepInfo>[];

    for (int i = 1; i <= 3; i++) {
      final relativeStart = overallStopwatch.elapsedMilliseconds;
      final stepStopwatch = Stopwatch()..start();

      final childSpan = FlutterOTel.tracer.startSpan(
        'step_$i',
        parentSpan: parentSpan,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      childSpan.end();
      stepStopwatch.stop();

      steps.add(_StepInfo(
        name: 'step_$i',
        spanId: childSpan.spanContext.spanId.toString(),
        durationMs: stepStopwatch.elapsedMilliseconds,
        relativeStartMs: relativeStart,
      ));
    }

    parentSpan.end();
    overallStopwatch.stop();

    setState(() {
      _isLoading = false;
      _traceId = parentSpan.spanContext.traceId.toString();
      _parentSpanId = parentSpan.spanContext.spanId.toString();
      _steps = steps;
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
            onPressed: _isLoading ? null : _runAsyncChain,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Run Async Chain'),
          ),
        ),
        if (_traceId != null) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Trace ID:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: Text(
                  _traceId!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Parent span
          _buildSpanTreeItem(
            context,
            name: 'async_chain',
            spanId: _parentSpanId!,
            indent: 0,
            isPrimary: true,
          ),
          // Child spans
          ..._steps.map(
            (step) => _buildSpanTreeItem(
              context,
              name: step.name,
              spanId: step.spanId,
              indent: 1,
              isPrimary: false,
              durationMs: step.durationMs,
              relativeStartMs: step.relativeStartMs,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpanTreeItem(
    BuildContext context, {
    required String name,
    required String spanId,
    required int indent,
    required bool isPrimary,
    int? durationMs,
    int? relativeStartMs,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = isPrimary ? colorScheme.primary : colorScheme.secondary;

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
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Span ID: $spanId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              if (durationMs != null && relativeStartMs != null)
                Text(
                  'Duration: $durationMs ms | Start: +$relativeStartMs ms',
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
