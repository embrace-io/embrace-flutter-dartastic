import 'dart:math';

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart'
    show Histogram;
import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class HistogramDemo extends StatefulWidget {
  const HistogramDemo({super.key});

  @override
  State<HistogramDemo> createState() => _HistogramDemoState();
}

class _HistogramDemoState extends State<HistogramDemo> {
  final List<double> _recordings = [];
  final Map<String, int> _buckets = {
    '0-100': 0,
    '100-500': 0,
    '500-1000': 0,
    '1000+': 0,
  };
  late final Histogram<double> _histogram;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _histogram = FlutterOTel.meter().createHistogram<double>(
      name: 'demo.response_time',
      unit: 'ms',
      boundaries: [100.0, 500.0, 1000.0, 2000.0],
    );
  }

  void _recordValue(double value) {
    _histogram.record(value);
    setState(() {
      _recordings.add(value);
      if (value < 100) {
        _buckets['0-100'] = (_buckets['0-100'] ?? 0) + 1;
      } else if (value < 500) {
        _buckets['100-500'] = (_buckets['100-500'] ?? 0) + 1;
      } else if (value < 1000) {
        _buckets['500-1000'] = (_buckets['500-1000'] ?? 0) + 1;
      } else {
        _buckets['1000+'] = (_buckets['1000+'] ?? 0) + 1;
      }
    });
  }

  void _recordRandom() {
    _recordValue(_random.nextDouble() * 1950 + 50); // 50-2000
  }

  void _recordFast() {
    _recordValue(_random.nextDouble() * 150 + 50); // 50-200
  }

  void _recordSlow() {
    _recordValue(_random.nextDouble() * 1000 + 1000); // 1000-2000
  }

  double get _min =>
      _recordings.isEmpty ? 0 : _recordings.reduce((a, b) => a < b ? a : b);

  double get _max =>
      _recordings.isEmpty ? 0 : _recordings.reduce((a, b) => a > b ? a : b);

  double get _average =>
      _recordings.isEmpty
          ? 0
          : _recordings.reduce((a, b) => a + b) / _recordings.length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: _recordRandom,
              child: const Text('Record Random'),
            ),
            ElevatedButton(
              onPressed: _recordFast,
              child: const Text('Record Fast'),
            ),
            ElevatedButton(
              onPressed: _recordSlow,
              child: const Text('Record Slow'),
            ),
          ],
        ),
        if (_recordings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _MetricDetailRow(
            label: 'Count',
            value: '${_recordings.length}',
          ),
          _MetricDetailRow(
            label: 'Min',
            value: '${_min.toStringAsFixed(1)} ms',
          ),
          _MetricDetailRow(
            label: 'Max',
            value: '${_max.toStringAsFixed(1)} ms',
          ),
          _MetricDetailRow(
            label: 'Average',
            value: '${_average.toStringAsFixed(1)} ms',
          ),
          const SizedBox(height: 12),
          ..._buckets.entries.map(
            (entry) => _BucketBar(
              label: entry.key,
              count: entry.value,
              maxCount: _recordings.length,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricDetailRow extends StatelessWidget {
  const _MetricDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
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
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }
}

class _BucketBar extends StatelessWidget {
  const _BucketBar({
    required this.label,
    required this.count,
    required this.maxCount,
  });

  final String label;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount > 0 ? count / maxCount : 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 16,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
