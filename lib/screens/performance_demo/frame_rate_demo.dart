import 'package:flutter/material.dart';

import 'frame_rate_tracker.dart';

class FrameRateDemo extends StatefulWidget {
  const FrameRateDemo({super.key});

  @override
  State<FrameRateDemo> createState() => _FrameRateDemoState();
}

class _FrameRateDemoState extends State<FrameRateDemo> {
  final _tracker = FrameRateTracker.instance;

  @override
  void initState() {
    super.initState();
    _tracker.addListener(_onChanged);
  }

  @override
  void dispose() {
    _tracker.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  Color _fpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final fps = _tracker.currentFps;
    final avg = _tracker.averageFps;
    final sparkline = _tracker.sparklineHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${fps.toStringAsFixed(1)} FPS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _fpsColor(fps),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
            ),
            Text(
              'Avg: ${avg.toStringAsFixed(1)} FPS',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sparkline.isNotEmpty)
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sparkline.map((value) {
                final fraction = (value / 120).clamp(0.0, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.5),
                    child: FractionallySizedBox(
                      heightFactor: fraction,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _fpsColor(value),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_tracker.isMonitoring) {
                _tracker.stop();
              } else {
                _tracker.start();
              }
            },
            child: Text(
              _tracker.isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
            ),
          ),
        ),
      ],
    );
  }
}
