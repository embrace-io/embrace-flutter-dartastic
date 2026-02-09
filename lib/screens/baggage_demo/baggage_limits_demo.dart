import 'dart:math';

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';

class BaggageLimitsDemo extends StatefulWidget {
  const BaggageLimitsDemo({
    super.key,
    required this.baggage,
    required this.onBaggageChanged,
  });

  final Baggage baggage;
  final ValueChanged<Baggage> onBaggageChanged;

  @override
  State<BaggageLimitsDemo> createState() => _BaggageLimitsDemoState();
}

class _BaggageLimitsDemoState extends State<BaggageLimitsDemo> {
  static const int _maxEntries = 180;
  static const int _maxBytes = 8192;

  String? _resultMessage;

  int _calculateTotalBytes() {
    final entries = widget.baggage.getAllEntries();
    var total = 0;
    for (final entry in entries.entries) {
      // key=value format plus comma separator
      total += entry.key.length + 1 + entry.value.value.length;
      if (entry.value.metadata != null) {
        total += 1 + entry.value.metadata!.length; // semicolon + metadata
      }
    }
    // Add commas between entries (one fewer than count)
    if (entries.length > 1) {
      total += entries.length - 1;
    }
    return total;
  }

  void _addLargeValue() {
    // Generate a 5KB+ value
    final largeValue = 'x' * 5120;
    try {
      final updated = widget.baggage.copyWith('large_value', largeValue);
      widget.onBaggageChanged(updated);
      setState(() {
        _resultMessage =
            'Added entry with ${largeValue.length}-byte value. '
            'Total size is now ${_calculateTotalBytesFor(updated)} bytes.';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error adding large value: $e';
      });
    }
  }

  int _calculateTotalBytesFor(Baggage baggage) {
    final entries = baggage.getAllEntries();
    var total = 0;
    for (final entry in entries.entries) {
      total += entry.key.length + 1 + entry.value.value.length;
      if (entry.value.metadata != null) {
        total += 1 + entry.value.metadata!.length;
      }
    }
    if (entries.length > 1) {
      total += entries.length - 1;
    }
    return total;
  }

  void _addManyEntries() {
    var updated = widget.baggage;
    final random = Random();
    try {
      for (var i = 0; i < 100; i++) {
        final key = 'key_${random.nextInt(100000)}';
        updated = updated.copyWith(key, 'val_$i');
      }
      widget.onBaggageChanged(updated);
      setState(() {
        _resultMessage =
            'Added 100 entries. Total count: ${updated.getAllEntries().length}.';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error adding many entries: $e';
      });
    }
  }

  Color _warningColor(double ratio) {
    if (ratio >= 0.9) return Colors.red;
    if (ratio >= 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.baggage.getAllEntries();
    final entryCount = entries.length;
    final totalBytes = _calculateTotalBytes();
    final entryRatio = entryCount / _maxEntries;
    final byteRatio = totalBytes / _maxBytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Entry Count'),
                  Text(
                    '$entryCount / $_maxEntries',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: _warningColor(entryRatio),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: entryRatio.clamp(0.0, 1.0),
                color: _warningColor(entryRatio),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Size'),
                  Text(
                    '$totalBytes / $_maxBytes bytes',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: _warningColor(byteRatio),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: byteRatio.clamp(0.0, 1.0),
                color: _warningColor(byteRatio),
                backgroundColor: Colors.grey.shade300,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _addLargeValue,
                child: const Text('Add Large Value'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _addManyEntries,
                child: const Text('Add Many Entries'),
              ),
            ),
          ],
        ),
        if (_resultMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _resultMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'W3C Baggage Limits',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Max entries: $_maxEntries\n'
          'Max total size: $_maxBytes bytes\n'
          'These limits are defined by the W3C Baggage specification.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Best Practices',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Keep baggage entries small and essential. '
          'Every entry is propagated with every request, '
          'so large or numerous entries add overhead. '
          'Use baggage for correlation IDs and routing hints, '
          'not for bulk data transfer.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}
