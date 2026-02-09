import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'sampling_statistics.dart';

class RateLimitingSamplerDemo extends StatefulWidget {
  const RateLimitingSamplerDemo({
    super.key,
    required this.spansPerSecond,
    required this.onRateChanged,
  });

  final double spansPerSecond;
  final ValueChanged<double> onRateChanged;

  @override
  State<RateLimitingSamplerDemo> createState() =>
      _RateLimitingSamplerDemoState();
}

class _SpanResult {
  const _SpanResult({required this.index, required this.wasSampled});

  final int index;
  final bool wasSampled;
}

class _RateLimitingSamplerDemoState extends State<RateLimitingSamplerDemo> {
  List<_SpanResult>? _results;

  void _burstSpans() {
    final results = <_SpanResult>[];

    for (int i = 0; i < 50; i++) {
      final span =
          FlutterOTel.tracer.startSpan('sampling.rate_limit_burst_$i');
      final wasSampled = span.isRecording;
      span.end();
      SamplingStatistics.instance.recordSpan(wasSampled: wasSampled);
      results.add(_SpanResult(index: i, wasSampled: wasSampled));
    }

    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rate = widget.spansPerSecond.round();
    final sampled = _results?.where((r) => r.wasSampled).length ?? 0;
    final dropped = (_results?.length ?? 0) - sampled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate Limit: $rate spans/sec',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: widget.spansPerSecond,
          min: 1.0,
          max: 100.0,
          divisions: 99,
          label: '$rate spans/sec',
          onChanged: widget.onRateChanged,
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: _burstSpans,
            child: const Text('Burst 50 Spans'),
          ),
        ),
        if (_results != null) ...[
          const SizedBox(height: 16),
          Text(
            '$sampled sampled, $dropped dropped',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _results!.length,
              itemBuilder: (context, index) {
                final result = _results![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color:
                            result.wasSampled ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Span ${result.index}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        result.wasSampled ? 'Sampled' : 'Dropped',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: result.wasSampled
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rate limiting uses a token bucket algorithm. '
                    'After a burst, wait 1+ second for the bucket to '
                    'refill and try again to see spans being sampled.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
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
