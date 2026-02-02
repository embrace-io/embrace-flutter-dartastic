import 'package:flutter/material.dart';

import 'launch_tracker.dart';

class LaunchTrackingDemo extends StatefulWidget {
  const LaunchTrackingDemo({super.key});

  @override
  State<LaunchTrackingDemo> createState() => _LaunchTrackingDemoState();
}

class _LaunchTrackingDemoState extends State<LaunchTrackingDemo> {
  final _tracker = LaunchTracker.instance;

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

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    final ms = time.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final coldStartMs = _tracker.coldStartDurationMs;
    final warmStarts = _tracker.warmStarts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.rocket_launch,
              size: 16,
              color: coldStartMs != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              coldStartMs != null
                  ? 'Cold Start: ${coldStartMs}ms'
                  : 'Cold Start: measuring...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Warm Starts',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (warmStarts.isEmpty)
          Text(
            'No warm starts recorded yet. Background and reopen the app.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          )
        else
          ...warmStarts.map(
            (ws) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.refresh, size: 14, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '${ws.durationMs}ms',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(ws.timestamp),
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
