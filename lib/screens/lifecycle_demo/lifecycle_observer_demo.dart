import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'lifecycle_event_store.dart';

class LifecycleObserverDemo extends StatefulWidget {
  const LifecycleObserverDemo({super.key});

  @override
  State<LifecycleObserverDemo> createState() => _LifecycleObserverDemoState();
}

class _LifecycleObserverDemoState extends State<LifecycleObserverDemo>
    with WidgetsBindingObserver {
  final _store = LifecycleEventStore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    final previous = _store.currentState;

    final span = FlutterOTel.tracer.startSpan('app.lifecycle_change');
    span.setStringAttribute('previous_state', previous.name);
    span.setStringAttribute('new_state', state.name);
    span.setStringAttribute('timestamp', now.toIso8601String());
    span.end();

    _store.recordTransition(state, now);
  }

  void _clearLog() {
    _store.clearLog();
  }

  Color _stateColor(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return Colors.green;
      case AppLifecycleState.inactive:
        return Colors.orange;
      case AppLifecycleState.paused:
        return Colors.red;
      case AppLifecycleState.detached:
        return Colors.grey;
      case AppLifecycleState.hidden:
        return Colors.blueGrey;
    }
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    final ms = time.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      final mins = duration.inMinutes;
      final secs = duration.inSeconds.remainder(60);
      return '+${mins}m ${secs}s';
    }
    final ms = duration.inMilliseconds;
    if (ms >= 1000) {
      return '+${(ms / 1000).toStringAsFixed(1)}s';
    }
    return '+${ms}ms';
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _store.currentState;
    final transitions = _store.transitions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 12, color: _stateColor(currentState)),
            const SizedBox(width: 8),
            Text(
              'Current State: ${currentState.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _clearLog,
            child: const Text('Clear Log'),
          ),
        ),
        const SizedBox(height: 12),
        if (transitions.isEmpty)
          Text(
            'No transitions recorded yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          )
        else
          ...transitions.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: _stateColor(t.next)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.previous.name} → ${t.next.name}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                        if (t.durationSinceLastEvent != null)
                          Text(
                            _formatDuration(t.durationSinceLastEvent!),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontFamily: 'monospace',
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(t.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
