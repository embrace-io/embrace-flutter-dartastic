import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart'
    show UpDownCounter;
import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class UpDownCounterDemo extends StatefulWidget {
  const UpDownCounterDemo({super.key});

  @override
  State<UpDownCounterDemo> createState() => _UpDownCounterDemoState();
}

class _UpDownCounterDemoState extends State<UpDownCounterDemo> {
  int _displayValue = 0;
  int? _lastChange;
  late final UpDownCounter<int> _upDownCounter;

  @override
  void initState() {
    super.initState();
    _upDownCounter = FlutterOTel.meter().createUpDownCounter<int>(
      name: 'demo.active_items',
      unit: '{item}',
    );
  }

  void _add(int value) {
    _upDownCounter.add(value);
    setState(() {
      _displayValue += value;
      _lastChange = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items in Cart',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_displayValue',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (_lastChange != null) ...[
                const SizedBox(width: 8),
                Icon(
                  _lastChange! > 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: _lastChange! > 0
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _add(-5),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
                child: const Text('-5'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _add(-1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
                child: const Text('-'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _add(1),
                child: const Text('+'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _add(5),
                child: const Text('+5'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
