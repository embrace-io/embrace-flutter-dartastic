import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class _IsolateResult {
  const _IsolateResult({
    required this.mainTraceId,
    required this.mainSpanId,
    required this.isolateTraceId,
    required this.isolateSpanId,
  });

  final String mainTraceId;
  final String mainSpanId;
  final String isolateTraceId;
  final String isolateSpanId;
}

class IsolateContextDemo extends StatefulWidget {
  const IsolateContextDemo({super.key});

  @override
  State<IsolateContextDemo> createState() => _IsolateContextDemoState();
}

class _IsolateContextDemoState extends State<IsolateContextDemo> {
  bool _isLoading = false;
  _IsolateResult? _result;
  String? _error;

  Future<void> _runInIsolate() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final parentSpan = FlutterOTel.tracer.startSpan('isolate_parent');
      final mainTraceId = parentSpan.spanContext.traceId.toString();
      final mainSpanId = parentSpan.spanContext.spanId.toString();

      final contextWithSpan = Context.current.withSpan(parentSpan);

      final isolateInfo = await contextWithSpan.runIsolate(() async {
        final childSpan = FlutterOTel.tracer.startSpan('isolate_work');

        // Simulate CPU-intensive work
        var sum = 0;
        for (var i = 0; i < 1000000; i++) {
          sum += i;
        }
        // Use sum to avoid dead code elimination
        childSpan.setIntAttribute('compute.result', sum);

        await Future.delayed(const Duration(milliseconds: 200));

        final traceId = childSpan.spanContext.traceId.toString();
        final spanId = childSpan.spanContext.spanId.toString();
        childSpan.end();

        return {'traceId': traceId, 'spanId': spanId};
      });

      parentSpan.end();

      setState(() {
        _isLoading = false;
        _result = _IsolateResult(
          mainTraceId: mainTraceId,
          mainSpanId: mainSpanId,
          isolateTraceId: isolateInfo['traceId']!,
          isolateSpanId: isolateInfo['spanId']!,
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Isolate error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _runInIsolate,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Run in Isolate'),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ],
        if (_result != null) ...[
          const SizedBox(height: 16),
          _buildIsolateBox(
            context,
            title: 'Main Isolate',
            traceId: _result!.mainTraceId,
            spanId: _result!.mainSpanId,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          _buildIsolateBox(
            context,
            title: 'Compute Isolate',
            traceId: _result!.isolateTraceId,
            spanId: _result!.isolateSpanId,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _result!.mainTraceId == _result!.isolateTraceId
                    ? Icons.check_circle
                    : Icons.error,
                size: 18,
                color: _result!.mainTraceId == _result!.isolateTraceId
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                _result!.mainTraceId == _result!.isolateTraceId
                    ? 'Trace IDs match across isolates'
                    : 'Trace IDs do not match',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _result!.mainTraceId == _result!.isolateTraceId
                          ? Colors.green
                          : Colors.red,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildIsolateBox(
    BuildContext context, {
    required String title,
    required String traceId,
    required String spanId,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trace ID: $traceId',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          Text(
            'Span ID: $spanId',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }
}
