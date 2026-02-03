import 'package:flutter/material.dart';

import 'traced_button.dart';

class TracedButtonDemo extends StatefulWidget {
  const TracedButtonDemo({super.key});

  @override
  State<TracedButtonDemo> createState() => _TracedButtonDemoState();
}

class _TracedButtonDemoState extends State<TracedButtonDemo> {
  String _lastTapped = 'None';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last tapped: $_lastTapped',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TracedButton(
              buttonName: 'elevated',
              onPressed: () => setState(() => _lastTapped = 'ElevatedButton'),
              buttonBuilder: (onPressed) => ElevatedButton(
                onPressed: onPressed,
                child: const Text('ElevatedButton'),
              ),
            ),
            TracedButton(
              buttonName: 'text',
              onPressed: () => setState(() => _lastTapped = 'TextButton'),
              buttonBuilder: (onPressed) => TextButton(
                onPressed: onPressed,
                child: const Text('TextButton'),
              ),
            ),
            TracedButton(
              buttonName: 'icon',
              onPressed: () => setState(() => _lastTapped = 'IconButton'),
              buttonBuilder: (onPressed) => IconButton(
                onPressed: onPressed,
                icon: const Icon(Icons.star),
                tooltip: 'IconButton',
              ),
            ),
            TracedButton(
              buttonName: 'disabled',
              onPressed: null,
              buttonBuilder: (onPressed) => ElevatedButton(
                onPressed: onPressed,
                child: const Text('Disabled'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
