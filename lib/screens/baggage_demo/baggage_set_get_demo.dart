import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';

class BaggageSetGetDemo extends StatefulWidget {
  const BaggageSetGetDemo({
    super.key,
    required this.baggage,
    required this.onBaggageChanged,
  });

  final Baggage baggage;
  final ValueChanged<Baggage> onBaggageChanged;

  @override
  State<BaggageSetGetDemo> createState() => _BaggageSetGetDemoState();
}

class _BaggageSetGetDemoState extends State<BaggageSetGetDemo> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _metadataController = TextEditingController();
  final _getKeyController = TextEditingController();
  String? _lookupResult;
  String? _validationError;

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _metadataController.dispose();
    _getKeyController.dispose();
    super.dispose();
  }

  void _setBaggage() {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();
    final metadata = _metadataController.text.trim();

    if (key.isEmpty || value.isEmpty) {
      setState(() {
        _validationError = 'Key and value are required.';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    final updated = widget.baggage.copyWith(
      key,
      value,
      metadata.isEmpty ? null : metadata,
    );
    widget.onBaggageChanged(updated);

    _keyController.clear();
    _valueController.clear();
    _metadataController.clear();
  }

  void _removeBaggage(String key) {
    final updated = widget.baggage.copyWithout(key);
    widget.onBaggageChanged(updated);
  }

  void _clearAll() {
    widget.onBaggageChanged(OTel.baggage());
  }

  void _getValue() {
    final key = _getKeyController.text.trim();
    if (key.isEmpty) return;

    final value = widget.baggage.getValue(key);
    setState(() {
      _lookupResult = value ?? 'Not found';
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.baggage.getAllEntries();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _keyController,
          decoration: const InputDecoration(
            labelText: 'Key',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _valueController,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _metadataController,
          decoration: const InputDecoration(
            labelText: 'Metadata (optional)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        if (_validationError != null) ...[
          const SizedBox(height: 4),
          Text(
            _validationError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: _setBaggage,
              child: const Text('Set Baggage'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: entries.isEmpty ? null : _clearAll,
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Current Entries',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        if (entries.isEmpty)
          Text(
            'No baggage entries set.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          )
        else
          ...entries.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.key} = ${entry.value.value}'
                      '${entry.value.metadata != null ? ' ; ${entry.value.metadata}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _removeBaggage(entry.key),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Remove',
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Look Up Value',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _getKeyController,
                decoration: const InputDecoration(
                  labelText: 'Key to look up',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _getValue,
              child: const Text('Get Value'),
            ),
          ],
        ),
        if (_lookupResult != null) ...[
          const SizedBox(height: 8),
          Text(
            'Result: $_lookupResult',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ],
    );
  }
}
