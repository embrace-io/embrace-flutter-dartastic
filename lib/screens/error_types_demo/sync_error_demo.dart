import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'demo_exception.dart';
import 'error_log_store.dart';

class SyncErrorDemo extends StatelessWidget {
  const SyncErrorDemo({super.key});

  void _throwException() {
    final span = FlutterOTel.tracer.startSpan('demo.sync_error.exception');
    try {
      throw Exception('Demo exception');
    } catch (e, st) {
      span.setStringAttribute('exception.type', 'Exception');
      span.setStringAttribute('exception.message', e.toString());
      span.setStatus(SpanStatusCode.Error, e.toString());
      FlutterOTel.reportError('sync_error', e, st);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'Exception',
        message: e.toString(),
        timestamp: DateTime.now(),
        source: 'sync',
      ));
    } finally {
      span.end();
    }
  }

  void _throwFormatException() {
    final span =
        FlutterOTel.tracer.startSpan('demo.sync_error.format_exception');
    try {
      throw const FormatException('Invalid format', 'abc', 0);
    } catch (e, st) {
      span.setStringAttribute('exception.type', 'FormatException');
      span.setStringAttribute('exception.message', e.toString());
      span.setStatus(SpanStatusCode.Error, e.toString());
      FlutterOTel.reportError('sync_error', e, st);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'FormatException',
        message: e.toString(),
        timestamp: DateTime.now(),
        source: 'sync',
      ));
    } finally {
      span.end();
    }
  }

  void _throwCustomException() {
    final span =
        FlutterOTel.tracer.startSpan('demo.sync_error.custom_exception');
    try {
      throw const DemoException('Custom error message');
    } catch (e, st) {
      span.setStringAttribute('exception.type', 'DemoException');
      span.setStringAttribute('exception.message', e.toString());
      span.setStatus(SpanStatusCode.Error, e.toString());
      FlutterOTel.reportError('sync_error', e, st);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'DemoException',
        message: e.toString(),
        timestamp: DateTime.now(),
        source: 'sync',
      ));
    } finally {
      span.end();
    }
  }

  void _throwStateError() {
    final span = FlutterOTel.tracer.startSpan('demo.sync_error.state_error');
    try {
      throw StateError('Bad state demo');
    } catch (e, st) {
      span.setStringAttribute('exception.type', 'StateError');
      span.setStringAttribute('exception.message', e.toString());
      span.setStatus(SpanStatusCode.Error, e.toString());
      FlutterOTel.reportError('sync_error', e, st);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'StateError',
        message: e.toString(),
        timestamp: DateTime.now(),
        source: 'sync',
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _throwException,
            child: const Text('Throw Exception'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _throwFormatException,
            child: const Text('Throw FormatException'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _throwCustomException,
            child: const Text('Throw Custom Exception'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _throwStateError,
            child: const Text('Throw StateError'),
          ),
        ),
      ],
    );
  }
}
