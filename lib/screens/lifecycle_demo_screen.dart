import 'package:flutter/material.dart';

import 'lifecycle_demo/foreground_tracking_demo.dart';
import 'lifecycle_demo/launch_tracking_demo.dart';
import 'lifecycle_demo/lifecycle_metrics_demo.dart';
import 'lifecycle_demo/lifecycle_observer_demo.dart';
import 'metrics_demo/demo_section.dart';

class LifecycleDemoScreen extends StatelessWidget {
  const LifecycleDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Lifecycle Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          DemoSection(
            title: 'Lifecycle Observer',
            description:
                'Monitors app lifecycle state changes using a '
                'WidgetsBindingObserver. Each transition emits an OTel span '
                'with previous state, new state, and timestamp attributes.',
            child: LifecycleObserverDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Launch Tracking',
            description:
                'Measures cold start time from main() to first frame render. '
                'Warm starts are tracked when the app returns from background.',
            child: LaunchTrackingDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Foreground / Background',
            description:
                'Tracks foreground session spans and background duration. '
                'Rapid state changes under 100ms are debounced to reduce noise.',
            child: ForegroundTrackingDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Lifecycle Metrics',
            description:
                'Aggregated OTel metrics: transition counter with type attribute, '
                'foreground/background duration histograms, and session duration gauge.',
            child: LifecycleMetricsDemo(),
          ),
        ],
      ),
    );
  }
}
