import 'package:flutter/material.dart';

import 'metrics_demo/counter_demo.dart';
import 'metrics_demo/counter_with_attributes_demo.dart';
import 'metrics_demo/demo_section.dart';
import 'metrics_demo/histogram_demo.dart';
import 'metrics_demo/up_down_counter_demo.dart';

class MetricsDemoScreen extends StatelessWidget {
  const MetricsDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Metrics Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          DemoSection(
            title: 'Counter',
            description:
                'A monotonically increasing counter that tracks cumulative '
                'values. Once incremented, the OTel counter never decreases. '
                'The display count can be reset locally.',
            child: CounterDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Counter with Attributes',
            description:
                'A counter that records values with dimensional attributes, '
                'allowing breakdowns by category. Each increment carries '
                'metadata for filtering and grouping.',
            child: CounterWithAttributesDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Histogram',
            description:
                'Records a distribution of values and automatically buckets '
                'them into configurable ranges. Useful for tracking things '
                'like response times or payload sizes.',
            child: HistogramDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'UpDownCounter',
            description:
                'A counter that supports both increments and decrements, '
                'useful for tracking values that go up and down like active '
                'connections or items in a queue.',
            child: UpDownCounterDemo(),
          ),
        ],
      ),
    );
  }
}
