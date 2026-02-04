import 'package:flutter/material.dart';

import 'sampling_statistics.dart';

class StatisticsPanel extends StatefulWidget {
  const StatisticsPanel({super.key});

  @override
  State<StatisticsPanel> createState() => _StatisticsPanelState();
}

class _StatisticsPanelState extends State<StatisticsPanel> {
  final _stats = SamplingStatistics.instance;

  @override
  void initState() {
    super.initState();
    _stats.addListener(_onStatsChanged);
  }

  @override
  void dispose() {
    _stats.removeListener(_onStatsChanged);
    super.dispose();
  }

  void _onStatsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(label: 'Created', value: '${_stats.spansCreated}'),
            _StatItem(label: 'Sampled', value: '${_stats.spansSampled}'),
            _StatItem(
              label: 'Sample Rate',
              value: '${_stats.sampleRate.toStringAsFixed(1)}%',
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _stats.resetStatistics(),
          child: const Text('Reset Statistics'),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
