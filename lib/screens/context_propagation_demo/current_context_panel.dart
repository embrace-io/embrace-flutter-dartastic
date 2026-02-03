import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class CurrentContextPanel extends StatefulWidget {
  const CurrentContextPanel({super.key});

  @override
  State<CurrentContextPanel> createState() => _CurrentContextPanelState();
}

class _CurrentContextPanelState extends State<CurrentContextPanel> {
  Timer? _timer;
  String? _traceId;
  String? _spanId;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _pollContext();
    });
  }

  void _pollContext() {
    final spanContext = Context.current.spanContext;
    final traceId =
        spanContext != null && spanContext.isValid
            ? spanContext.traceId.toString()
            : null;
    final spanId =
        spanContext != null && spanContext.isValid
            ? spanContext.spanId.toString()
            : null;

    if (traceId != _traceId || spanId != _spanId) {
      setState(() {
        _traceId = traceId;
        _spanId = spanId;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasContext = _traceId != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            hasContext
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasContext ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child:
          hasContext
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trace ID:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _traceId!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Span ID:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _spanId!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              )
              : Text(
                'No active context',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
    );
  }
}
