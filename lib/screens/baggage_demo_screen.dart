import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';

import 'baggage_demo/baggage_in_spans_demo.dart';
import 'baggage_demo/baggage_limits_demo.dart';
import 'baggage_demo/baggage_propagation_demo.dart';
import 'baggage_demo/baggage_set_get_demo.dart';
import 'metrics_demo/demo_section.dart';

class BaggageDemoScreen extends StatefulWidget {
  const BaggageDemoScreen({super.key});

  @override
  State<BaggageDemoScreen> createState() => _BaggageDemoScreenState();
}

class _BaggageDemoScreenState extends State<BaggageDemoScreen> {
  Baggage _baggage = OTel.baggage();

  void _onBaggageChanged(Baggage newBaggage) {
    setState(() {
      _baggage = newBaggage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Baggage Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Baggage is used to propagate key-value pairs across '
                      'service boundaries. It carries user-defined context '
                      'alongside trace context, useful for correlation IDs, '
                      'tenant info, and feature flags.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DemoSection(
            title: 'Set & Get Baggage',
            description:
                'Add, remove, and query baggage entries with keys, values, and metadata.',
            child: BaggageSetGetDemo(
              baggage: _baggage,
              onBaggageChanged: _onBaggageChanged,
            ),
          ),
          const SizedBox(height: 16),
          DemoSection(
            title: 'Baggage Propagation',
            description:
                'Send baggage as a W3C header in HTTP requests and see the echoed response.',
            child: BaggagePropagationDemo(baggage: _baggage),
          ),
          const SizedBox(height: 16),
          DemoSection(
            title: 'Baggage in Spans',
            description:
                'Copy baggage entries as span attributes for observability.',
            child: BaggageInSpansDemo(baggage: _baggage),
          ),
          const SizedBox(height: 16),
          DemoSection(
            title: 'Baggage Limits',
            description:
                'Explore W3C baggage size and entry count limits.',
            child: BaggageLimitsDemo(
              baggage: _baggage,
              onBaggageChanged: _onBaggageChanged,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
