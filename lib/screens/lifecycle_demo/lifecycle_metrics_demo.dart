import 'package:flutter/material.dart';

import 'lifecycle_metrics.dart';

class LifecycleMetricsDemo extends StatefulWidget {
  const LifecycleMetricsDemo({super.key});

  @override
  State<LifecycleMetricsDemo> createState() => _LifecycleMetricsDemoState();
}

class _LifecycleMetricsDemoState extends State<LifecycleMetricsDemo> {
  final _metrics = LifecycleMetrics.instance;

  @override
  void initState() {
    super.initState();
    _metrics.addListener(_onMetricsChanged);
  }

  @override
  void dispose() {
    _metrics.removeListener(_onMetricsChanged);
    super.dispose();
  }

  void _onMetricsChanged() {
    setState(() {});
  }

  String _formatMs(int ms) {
    if (ms < 1000) return '${ms}ms';
    if (ms < 60000) return '${(ms / 1000).toStringAsFixed(1)}s';
    final mins = ms ~/ 60000;
    final secs = (ms % 60000) ~/ 1000;
    return '${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(
          label: 'Total Transitions',
          value: '${_metrics.totalTransitions}',
        ),
        const SizedBox(height: 4),
        _MetricRow(
          label: 'Longest Foreground',
          value: _formatMs(_metrics.longestForegroundMs),
        ),
        const SizedBox(height: 4),
        _MetricRow(
          label: 'Longest Background',
          value: _formatMs(_metrics.longestBackgroundMs),
        ),
        const SizedBox(height: 4),
        _MetricRow(
          label: 'Session Duration',
          value: _formatMs(_metrics.sessionDurationMs),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
