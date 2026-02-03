import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'error_log_store.dart';

class AsyncErrorDemo extends StatefulWidget {
  const AsyncErrorDemo({super.key});

  @override
  State<AsyncErrorDemo> createState() => _AsyncErrorDemoState();
}

class _AsyncErrorDemoState extends State<AsyncErrorDemo> {
  String? _activeButton;

  bool get _isLoading => _activeButton != null;

  Future<void> _futureError() async {
    setState(() => _activeButton = 'future');
    final span = FlutterOTel.tracer.startSpan('demo.async_error.future');
    span.setStringAttribute('error.source', 'future');

    await Future.delayed(const Duration(milliseconds: 500));

    await Future<void>.error(Exception('Future.error demo'))
        .catchError((Object e, StackTrace st) {
      span.setStringAttribute('exception.type', 'Exception');
      span.setStringAttribute('exception.message', e.toString());
      span.setStatus(SpanStatusCode.Error, e.toString());
      FlutterOTel.reportError('async_error', e, st);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'Future.error',
        message: e.toString(),
        timestamp: DateTime.now(),
        source: 'async',
      ));
    });

    span.end();
    if (mounted) setState(() => _activeButton = null);
  }

  Future<void> _asyncException() async {
    setState(() => _activeButton = 'async_function');
    final span =
        FlutterOTel.tracer.startSpan('demo.async_error.async_function');
    span.setStringAttribute('error.source', 'async_function');

    try {
      await _delayedThrow();
    } catch (e, st) {
      span.setStringAttribute('exception.type', e.runtimeType.toString());
      span.setStringAttribute('exception.message', e.toString());
      span.setStatus(SpanStatusCode.Error, e.toString());
      FlutterOTel.reportError('async_error', e, st);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'Async Exception',
        message: e.toString(),
        timestamp: DateTime.now(),
        source: 'async',
      ));
    } finally {
      span.end();
      if (mounted) setState(() => _activeButton = null);
    }
  }

  Future<void> _delayedThrow() async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw StateError('Async function error after delay');
  }

  Future<void> _streamError() async {
    setState(() => _activeButton = 'stream');
    final span = FlutterOTel.tracer.startSpan('demo.async_error.stream');
    span.setStringAttribute('error.source', 'stream');

    await Future.delayed(const Duration(milliseconds: 500));

    final completer = Completer<void>();
    final stream = Stream<int>.error(Exception('Stream error demo'));

    stream.listen(
      null,
      onError: (Object e, StackTrace st) {
        span.setStringAttribute('exception.type', e.runtimeType.toString());
        span.setStringAttribute('exception.message', e.toString());
        span.setStatus(SpanStatusCode.Error, e.toString());
        FlutterOTel.reportError('async_error', e, st);
        ErrorLogStore.instance.addEntry(ErrorLogEntry(
          errorType: 'Stream.error',
          message: e.toString(),
          timestamp: DateTime.now(),
          source: 'async',
        ));
        span.end();
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
    if (mounted) setState(() => _activeButton = null);
  }

  Future<void> _uncaughtAsync() async {
    setState(() => _activeButton = 'uncaught');
    final span =
        FlutterOTel.tracer.startSpan('demo.async_error.uncaught_async');
    span.setStringAttribute('error.source', 'uncaught_async');

    final completer = Completer<void>();

    runZonedGuarded(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception('Uncaught async error demo');
    }, (error, stack) {
      span.setStringAttribute('exception.type', error.runtimeType.toString());
      span.setStringAttribute('exception.message', error.toString());
      span.setStatus(SpanStatusCode.Error, error.toString());
      FlutterOTel.reportError('async_error', error, stack);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'Uncaught Async',
        message: error.toString(),
        timestamp: DateTime.now(),
        source: 'async',
      ));
      span.end();
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;
    if (mounted) setState(() => _activeButton = null);
  }

  Widget _buildButton({
    required String label,
    required String key,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        child: _activeButton == key
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildButton(
          label: 'Future.error',
          key: 'future',
          onPressed: _futureError,
        ),
        const SizedBox(height: 8),
        _buildButton(
          label: 'Async Exception',
          key: 'async_function',
          onPressed: _asyncException,
        ),
        const SizedBox(height: 8),
        _buildButton(
          label: 'Stream Error',
          key: 'stream',
          onPressed: _streamError,
        ),
        const SizedBox(height: 8),
        _buildButton(
          label: 'Uncaught Async',
          key: 'uncaught',
          onPressed: _uncaughtAsync,
        ),
      ],
    );
  }
}
