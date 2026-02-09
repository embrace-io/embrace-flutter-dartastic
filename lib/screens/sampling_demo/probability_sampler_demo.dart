import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'sampling_statistics.dart';

class ProbabilitySamplerDemo extends StatefulWidget {
  const ProbabilitySamplerDemo({
    super.key,
    required this.ratio,
    required this.onRatioChanged,
  });

  final double ratio;
  final ValueChanged<double> onRatioChanged;

  @override
  State<ProbabilitySamplerDemo> createState() => _ProbabilitySamplerDemoState();
}

class _ProbabilitySamplerDemoState extends State<ProbabilitySamplerDemo> {
  int? _sampledCount;
  int? _totalCount;

  void _generateSpans() {
    int sampled = 0;
    const total = 100;

    for (int i = 0; i < total; i++) {
      final span = FlutterOTel.tracer.startSpan('sampling.probability_test_$i');
      final wasSampled = span.isRecording;
      span.end();
      SamplingStatistics.instance.recordSpan(wasSampled: wasSampled);
      if (wasSampled) sampled++;
    }

    setState(() {
      _sampledCount = sampled;
      _totalCount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sampling Probability: $percentage%',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: widget.ratio,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '$percentage%',
          onChanged: widget.onRatioChanged,
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: _generateSpans,
            child: const Text('Generate 100 Spans'),
          ),
        ),
        if (_sampledCount != null && _totalCount != null) ...[
          const SizedBox(height: 16),
          Text(
            '$_sampledCount sampled out of $_totalCount',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  if (_sampledCount! > 0)
                    Expanded(
                      flex: _sampledCount!,
                      child: Container(color: Colors.green),
                    ),
                  if (_sampledCount! < _totalCount!)
                    Expanded(
                      flex: _totalCount! - _sampledCount!,
                      child: Container(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sampled: $_sampledCount',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.green),
              ),
              Text(
                'Dropped: ${_totalCount! - _sampledCount!}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red),
              ),
            ],
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
                    'Trace ID ratio sampling is deterministic per trace ID. '
                    'The same trace ID will always produce the same sampling '
                    'decision for a given ratio.',
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
