import 'package:flutter/material.dart';

import 'error_log_store.dart';

class ErrorLogPanel extends StatefulWidget {
  const ErrorLogPanel({super.key});

  @override
  State<ErrorLogPanel> createState() => _ErrorLogPanelState();
}

class _ErrorLogPanelState extends State<ErrorLogPanel> {
  final _store = ErrorLogStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
  }

  Color _sourceColor(String source) {
    switch (source) {
      case 'sync':
        return Colors.orange;
      case 'async':
        return Colors.blue;
      case 'flutter':
        return Colors.red;
      case 'context':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _sourceIcon(String source) {
    switch (source) {
      case 'sync':
        return Icons.sync;
      case 'async':
        return Icons.schedule;
      case 'flutter':
        return Icons.widgets;
      case 'context':
        return Icons.info;
      default:
        return Icons.error;
    }
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    final ms = time.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final entries = _store.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Error Log (${entries.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            OutlinedButton(
              onPressed: entries.isEmpty ? null : _store.clear,
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Text(
            'No errors recorded yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final color = _sourceColor(entry.source);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(_sourceIcon(entry.source), size: 14, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${entry.errorType}: ${entry.message}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontFamily: 'monospace',
                                color: color,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(entry.timestamp),
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
