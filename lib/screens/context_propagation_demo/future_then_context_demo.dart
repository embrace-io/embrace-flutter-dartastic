import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class _CallbackResult {
  const _CallbackResult({
    required this.name,
    required this.traceId,
    required this.spanId,
  });

  final String name;
  final String traceId;
  final String spanId;
}

class FutureThenContextDemo extends StatefulWidget {
  const FutureThenContextDemo({super.key});

  @override
  State<FutureThenContextDemo> createState() => _FutureThenContextDemoState();
}

class _FutureThenContextDemoState extends State<FutureThenContextDemo> {
  bool _isLoadingCorrect = false;
  bool _isLoadingIncorrect = false;
  List<_CallbackResult>? _correctResults;
  List<_CallbackResult>? _incorrectResults;

  bool get _isLoading => _isLoadingCorrect || _isLoadingIncorrect;

  Future<void> _runCorrectPattern() async {
    setState(() {
      _isLoadingCorrect = true;
      _correctResults = null;
    });

    final parentSpan = FlutterOTel.tracer.startSpan('correct_callback_chain');
    final results = <_CallbackResult>[];

    await Future.delayed(const Duration(milliseconds: 200)).then((_) {
      final span = FlutterOTel.tracer.startSpan(
        'processA',
        parentSpan: parentSpan,
      );
      results.add(_CallbackResult(
        name: 'processA',
        traceId: span.spanContext.traceId.toString(),
        spanId: span.spanContext.spanId.toString(),
      ));
      span.end();
      return Future.delayed(const Duration(milliseconds: 200));
    }).then((_) {
      final span = FlutterOTel.tracer.startSpan(
        'processB',
        parentSpan: parentSpan,
      );
      results.add(_CallbackResult(
        name: 'processB',
        traceId: span.spanContext.traceId.toString(),
        spanId: span.spanContext.spanId.toString(),
      ));
      span.end();
      return Future.delayed(const Duration(milliseconds: 200));
    }).then((_) {
      final span = FlutterOTel.tracer.startSpan(
        'processC',
        parentSpan: parentSpan,
      );
      results.add(_CallbackResult(
        name: 'processC',
        traceId: span.spanContext.traceId.toString(),
        spanId: span.spanContext.spanId.toString(),
      ));
      span.end();
    });

    parentSpan.end();

    setState(() {
      _isLoadingCorrect = false;
      _correctResults = results;
    });
  }

  Future<void> _runIncorrectPattern() async {
    setState(() {
      _isLoadingIncorrect = true;
      _incorrectResults = null;
    });

    final results = <_CallbackResult>[];

    await Future.delayed(const Duration(milliseconds: 200)).then((_) {
      final span = FlutterOTel.tracer.startSpan('processA_no_parent');
      results.add(_CallbackResult(
        name: 'processA',
        traceId: span.spanContext.traceId.toString(),
        spanId: span.spanContext.spanId.toString(),
      ));
      span.end();
      return Future.delayed(const Duration(milliseconds: 200));
    }).then((_) {
      final span = FlutterOTel.tracer.startSpan('processB_no_parent');
      results.add(_CallbackResult(
        name: 'processB',
        traceId: span.spanContext.traceId.toString(),
        spanId: span.spanContext.spanId.toString(),
      ));
      span.end();
      return Future.delayed(const Duration(milliseconds: 200));
    }).then((_) {
      final span = FlutterOTel.tracer.startSpan('processC_no_parent');
      results.add(_CallbackResult(
        name: 'processC',
        traceId: span.spanContext.traceId.toString(),
        spanId: span.spanContext.spanId.toString(),
      ));
      span.end();
    });

    setState(() {
      _isLoadingIncorrect = false;
      _incorrectResults = results;
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
            onPressed: _isLoading ? null : _runCorrectPattern,
            child: _isLoadingCorrect
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Run Correct Pattern'),
          ),
        ),
        if (_correctResults != null) ...[
          const SizedBox(height: 12),
          _buildResultSection(
            context,
            results: _correctResults!,
            isCorrect: true,
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _runIncorrectPattern,
            child: _isLoadingIncorrect
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Run Incorrect Pattern'),
          ),
        ),
        if (_incorrectResults != null) ...[
          const SizedBox(height: 12),
          _buildResultSection(
            context,
            results: _incorrectResults!,
            isCorrect: false,
          ),
        ],
        if (_correctResults != null || _incorrectResults != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'The correct pattern uses explicit parentSpan: to maintain '
              'parent-child relationships in Future.then() callbacks. Without '
              'it, each span starts a new trace because callback context is '
              'not automatically propagated.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultSection(
    BuildContext context, {
    required List<_CallbackResult> results,
    required bool isCorrect,
  }) {
    final allSameTrace = results.isNotEmpty &&
        results.every((r) => r.traceId == results.first.traceId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.warning,
              size: 18,
              color: isCorrect ? Colors.green : Colors.amber,
            ),
            const SizedBox(width: 6),
            Text(
              allSameTrace ? 'All trace IDs match' : 'Trace IDs differ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: allSameTrace ? Colors.green : Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...results.map(
          (result) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                ),
                Text(
                  'Trace: ${result.traceId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
