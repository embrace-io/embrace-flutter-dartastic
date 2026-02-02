import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart'
    show Counter;
import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class CounterWithAttributesDemo extends StatefulWidget {
  const CounterWithAttributesDemo({super.key});

  @override
  State<CounterWithAttributesDemo> createState() =>
      _CounterWithAttributesDemoState();
}

class _CounterWithAttributesDemoState
    extends State<CounterWithAttributesDemo> {
  static const _categories = ['purchase', 'view', 'share', 'favorite'];

  String _selectedCategory = 'purchase';
  final Map<String, int> _categoryCounts = {
    for (final c in _categories) c: 0,
  };

  late final Counter<int> _counter;

  @override
  void initState() {
    super.initState();
    _counter = FlutterOTel.meter().createCounter<int>(
      name: 'demo.categorized_actions',
    );
  }

  void _recordAction() {
    _counter.add(
      1,
      <String, Object>{'action.type': _selectedCategory}.toAttributes(),
    );
    setState(() {
      _categoryCounts[_selectedCategory] =
          (_categoryCounts[_selectedCategory] ?? 0) + 1;
    });
  }

  int get _total => _categoryCounts.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<String>(
          segments: _categories
              .map((c) => ButtonSegment<String>(value: c, label: Text(c)))
              .toList(),
          selected: {_selectedCategory},
          onSelectionChanged: (selected) {
            setState(() {
              _selectedCategory = selected.first;
            });
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _recordAction,
            child: const Text('Record Action'),
          ),
        ),
        if (_total > 0) ...[
          const SizedBox(height: 16),
          ..._categories.map(
            (c) => _CategoryRow(
              category: c,
              count: _categoryCounts[c] ?? 0,
            ),
          ),
          const Divider(),
          _CategoryRow(category: 'Total', count: _total),
        ],
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.count,
  });

  final String category;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
