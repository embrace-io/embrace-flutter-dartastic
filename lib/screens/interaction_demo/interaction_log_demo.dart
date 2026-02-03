import 'package:flutter/material.dart';

import 'interaction_log_store.dart';

class InteractionLogDemo extends StatefulWidget {
  const InteractionLogDemo({super.key});

  @override
  State<InteractionLogDemo> createState() => _InteractionLogDemoState();
}

class _InteractionLogDemoState extends State<InteractionLogDemo> {
  final _store = InteractionLogStore.instance;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
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
    // Display oldest-first (entries are stored newest-first).
    final displayEntries = entries.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _store.clearLog,
            child: const Text('Clear Log'),
          ),
        ),
        const SizedBox(height: 12),
        if (displayEntries.isEmpty)
          Text(
            'No interactions recorded yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: displayEntries.length,
              itemBuilder: (context, index) {
                final entry = displayEntries[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${entry.widgetType}: ${entry.action}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                      Text(
                        _formatTime(entry.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
