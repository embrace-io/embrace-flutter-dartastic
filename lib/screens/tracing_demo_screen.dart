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
      body: const Center(
        child: Text('Tracing Demo Screen'),
      ),
    );
  }
}
