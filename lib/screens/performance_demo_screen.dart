import 'package:flutter/material.dart';

import 'metrics_demo/demo_section.dart';
import 'performance_demo/frame_metrics_demo.dart';
import 'performance_demo/frame_rate_demo.dart';
import 'performance_demo/jank_detection_demo.dart';
import 'performance_demo/jank_simulation_demo.dart';

class PerformanceDemoScreen extends StatelessWidget {
  const PerformanceDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Performance Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          DemoSection(
            title: 'Frame Rate',
            description:
                'Monitors real-time frame rate using SchedulerBinding '
                'timings callback. Displays current FPS, rolling average, '
                'and a sparkline history chart.',
            child: FrameRateDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Jank Detection',
            description:
                'Classifies frames as normal (<=16ms), jank (>16ms), or '
                'severe (>32ms). Tracks counts and jank percentage with '
                'OTel counter and histogram instrumentation.',
            child: JankDetectionDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Jank Simulation',
            description:
                'Intentionally blocks the UI thread with a busy loop to '
                'demonstrate jank detection. Compare with smooth animation '
                'to see the difference.',
            child: JankSimulationDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Frame Metrics',
            description:
                'Records build, raster, and total frame times into OTel '
                'histograms. Displays p50/p90/p95/p99 percentiles and '
                'budget utilization.',
            child: FrameMetricsDemo(),
          ),
        ],
      ),
    );
  }
}
