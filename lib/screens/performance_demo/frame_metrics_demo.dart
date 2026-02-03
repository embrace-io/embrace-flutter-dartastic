import 'package:flutter/material.dart';

import 'frame_metrics_exporter.dart';

class FrameMetricsDemo extends StatefulWidget {
  const FrameMetricsDemo({super.key});

  @override
  State<FrameMetricsDemo> createState() => _FrameMetricsDemoState();
}

class _FrameMetricsDemoState extends State<FrameMetricsDemo> {
  final _exporter = FrameMetricsExporter.instance;

  @override
  void initState() {
    super.initState();
    _exporter.addListener(_onChanged);
  }

  @override
  void dispose() {
    _exporter.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  String _fmtMs(double ms) => '${ms.toStringAsFixed(1)} ms';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(label: 'Samples', value: '${_exporter.sampleCount}'),
        const SizedBox(height: 4),
        _MetricRow(
          label: 'Budget Utilization',
          value: '${_exporter.budgetUtilization.toStringAsFixed(1)}%',
        ),
        const Divider(height: 16),
        Text('Build Time', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        _MetricRow(label: 'p50', value: _fmtMs(_exporter.buildP50)),
        _MetricRow(label: 'p90', value: _fmtMs(_exporter.buildP90)),
        _MetricRow(label: 'p95', value: _fmtMs(_exporter.buildP95)),
        _MetricRow(label: 'p99', value: _fmtMs(_exporter.buildP99)),
        const Divider(height: 16),
        Text('Raster Time', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        _MetricRow(label: 'p50', value: _fmtMs(_exporter.rasterP50)),
        _MetricRow(label: 'p90', value: _fmtMs(_exporter.rasterP90)),
        _MetricRow(label: 'p95', value: _fmtMs(_exporter.rasterP95)),
        _MetricRow(label: 'p99', value: _fmtMs(_exporter.rasterP99)),
        const Divider(height: 16),
        Text('Total Time', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        _MetricRow(label: 'p50', value: _fmtMs(_exporter.totalP50)),
        _MetricRow(label: 'p90', value: _fmtMs(_exporter.totalP90)),
        _MetricRow(label: 'p95', value: _fmtMs(_exporter.totalP95)),
        _MetricRow(label: 'p99', value: _fmtMs(_exporter.totalP99)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _exporter.resetDisplay,
            child: const Text('Reset Metrics'),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
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
      ),
    );
  }
}
