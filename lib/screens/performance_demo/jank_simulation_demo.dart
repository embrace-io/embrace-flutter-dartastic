import 'package:flutter/material.dart';

import 'jank_simulator.dart';

class JankSimulationDemo extends StatefulWidget {
  const JankSimulationDemo({super.key});

  @override
  State<JankSimulationDemo> createState() => _JankSimulationDemoState();
}

class _JankSimulationDemoState extends State<JankSimulationDemo> {
  double _durationMs = 150;
  bool _smoothAnimating = false;

  void _causeJank() {
    JankSimulator.causeJank(_durationMs.round());
  }

  void _toggleSmooth() {
    setState(() {
      _smoothAnimating = !_smoothAnimating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Duration:'),
            Expanded(
              child: Slider(
                value: _durationMs,
                min: 100,
                max: 200,
                divisions: 10,
                label: '${_durationMs.round()} ms',
                onChanged: (value) {
                  setState(() => _durationMs = value);
                },
              ),
            ),
            Text(
              '${_durationMs.round()} ms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _causeJank,
            child: const Text('Cause Jank'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _toggleSmooth,
            child: const Text('Cause Smooth Animation'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Warning: Cause Jank intentionally blocks the UI thread.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
              ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          width: _smoothAnimating ? 200 : 50,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
