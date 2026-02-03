import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'error_log_store.dart';

class ErrorWithContextDemo extends StatefulWidget {
  const ErrorWithContextDemo({super.key});

  @override
  State<ErrorWithContextDemo> createState() => _ErrorWithContextDemoState();
}

class _ErrorWithContextDemoState extends State<ErrorWithContextDemo> {
  final _userIdController = TextEditingController();
  final _sessionIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _sessionIdController.dispose();
    super.dispose();
  }

  void _triggerErrorWithContext() {
    final span =
        FlutterOTel.tracer.startSpan('demo.error_with_context');

    final userId = _userIdController.text.isEmpty
        ? 'anonymous'
        : _userIdController.text;
    final sessionId = _sessionIdController.text.isEmpty
        ? 'no-session'
        : _sessionIdController.text;

    span.setStringAttribute('user.id', userId);
    span.setStringAttribute('session.id', sessionId);
    span.setStringAttribute('screen_name', 'errors_demo');

    // Add recent error log entries as breadcrumb events.
    final recentEntries = ErrorLogStore.instance.entries.take(5).toList();
    span.setIntAttribute('breadcrumb_count', recentEntries.length);

    for (final entry in recentEntries) {
      span.addEventNow(
        'breadcrumb',
        {
          'error_type': entry.errorType,
          'message': entry.message,
          'source': entry.source,
        }.toAttributes(),
      );
    }

    try {
      throw StateError('Contextual error with user=$userId');
    } catch (e, st) {
      span.setStringAttribute('exception.type', 'StateError');
      span.setStringAttribute('exception.message', e.toString());
      span.setStatus(SpanStatusCode.Error, e.toString());
      FlutterOTel.reportError('context_error', e, st);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'Context Error',
        message: 'user=$userId session=$sessionId '
            'breadcrumbs=${recentEntries.length}',
        timestamp: DateTime.now(),
        source: 'context',
      ));
    } finally {
      span.end();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _userIdController,
          decoration: const InputDecoration(
            labelText: 'User ID',
            hintText: 'Enter a user identifier',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _sessionIdController,
          decoration: const InputDecoration(
            labelText: 'Session ID',
            hintText: 'Enter a session identifier',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _triggerErrorWithContext,
            child: const Text('Error with Context'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Note: In production, user data should be sanitized '
          'before attaching to telemetry.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}
