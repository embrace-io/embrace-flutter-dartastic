import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dartastic Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/tracing'),
              child: const Text('Tracing Demo'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/metrics'),
              child: const Text('Metrics Demo'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/lifecycle'),
              child: const Text('Lifecycle Demo'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/performance'),
              child: const Text('Performance Demo'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/interactions'),
              child: const Text('Interactions Demo'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/errors'),
              child: const Text('Errors Demo'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/context'),
              child: const Text('Context Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
