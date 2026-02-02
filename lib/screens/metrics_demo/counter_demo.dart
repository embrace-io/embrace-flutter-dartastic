import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart'
    show Counter;
import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class CounterDemo extends StatefulWidget {
  const CounterDemo({super.key});

  @override
  State<CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<CounterDemo> {
  int _displayCount = 0;
  late final Counter<int> _counter;

  @override
  void initState() {
    super.initState();
    _counter = FlutterOTel.meter().createCounter<int>(
      name: 'demo.button_clicks',
      unit: '{click}',
    );
  }

  void _increment() {
    _counter.add(1);
    setState(() {
      _displayCount++;
    });
  }

  void _resetDisplay() {
    setState(() {
      _displayCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            '$_displayCount',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _increment,
            child: const Text('Increment'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetDisplay,
            child: const Text('Reset Display'),
          ),
        ),
      ],
    );
  }
}
