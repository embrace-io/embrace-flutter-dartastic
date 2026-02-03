import 'package:flutter/material.dart';

import 'interaction_demo/form_interaction_demo.dart';
import 'interaction_demo/interaction_log_demo.dart';
import 'interaction_demo/scroll_tracking_demo.dart';
import 'interaction_demo/traced_button_demo.dart';
import 'interaction_demo/traced_gesture_demo.dart';
import 'metrics_demo/demo_section.dart';

class InteractionDemoScreen extends StatelessWidget {
  const InteractionDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Interactions Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          DemoSection(
            title: 'Interaction Log',
            description:
                'Real-time log of all widget interactions. Shows widget '
                'type, action, and timestamp for each traced event.',
            child: InteractionLogDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Traced Buttons',
            description:
                'Buttons wrapped with OpenTelemetry tracing. Each tap '
                'creates a span with button name and enabled state.',
            child: TracedButtonDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Gesture Tracking',
            description:
                'Detects and traces tap, long-press, double-tap, and '
                'drag gestures with position and velocity attributes.',
            child: TracedGestureDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Form Interaction Tracking',
            description:
                'Tracks field focus duration and submit events. Creates '
                'parent-child spans linking field interactions to form submission.',
            child: FormInteractionDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Scroll Tracking',
            description:
                'Monitors scroll start/end with debounced span creation. '
                'Tracks scroll direction, distance, and peak velocity.',
            child: ScrollTrackingDemo(),
          ),
        ],
      ),
    );
  }
}
