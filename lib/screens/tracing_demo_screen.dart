import 'package:flutter/material.dart';

class TracingDemoScreen extends StatelessWidget {
  const TracingDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tracing Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _DemoSection(
            title: 'Single Span',
            child: Placeholder(fallbackHeight: 100),
          ),
          SizedBox(height: 16),
          _DemoSection(
            title: 'Nested Spans',
            child: Placeholder(fallbackHeight: 100),
          ),
          SizedBox(height: 16),
          _DemoSection(
            title: 'Span Events',
            child: Placeholder(fallbackHeight: 100),
          ),
          SizedBox(height: 16),
          _DemoSection(
            title: 'Span Status',
            child: Placeholder(fallbackHeight: 100),
          ),
        ],
      ),
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
