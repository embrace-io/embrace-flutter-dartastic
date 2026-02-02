import 'package:flutter/material.dart';

import 'foreground_tracker.dart';

class ForegroundTrackingDemo extends StatefulWidget {
  const ForegroundTrackingDemo({super.key});

  @override
  State<ForegroundTrackingDemo> createState() => _ForegroundTrackingDemoState();
}

class _ForegroundTrackingDemoState extends State<ForegroundTrackingDemo> {
  final _tracker = ForegroundTracker.instance;

  @override
  void initState() {
    super.initState();
    _tracker.addListener(_onTrackerChanged);
  }

  @override
  void dispose() {
    _tracker.removeListener(_onTrackerChanged);
    super.dispose();
  }

  void _onTrackerChanged() {
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
    final isFg = _tracker.isForeground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 12,
              color: isFg ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              isFg ? 'Foreground' : 'Background',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatRow(
          label: 'Cumulative Foreground',
          value: _formatMs(_tracker.cumulativeForegroundMs),
        ),
        const SizedBox(height: 4),
        _StatRow(
          label: 'Cumulative Background',
          value: _formatMs(_tracker.cumulativeBackgroundMs),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

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
