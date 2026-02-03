import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'error_log_store.dart';

class FlutterErrorDemo extends StatefulWidget {
  const FlutterErrorDemo({super.key});

  @override
  State<FlutterErrorDemo> createState() => _FlutterErrorDemoState();
}

class _FlutterErrorDemoState extends State<FlutterErrorDemo> {
  bool _safeMode = true;
  _ErrorType? _activeError;

  void _triggerBuildError() {
    final span = FlutterOTel.tracer.startSpan('demo.flutter_error.build');
    span.setStringAttribute('error.type', 'build_error');
    span.setStringAttribute('safe_mode', _safeMode.toString());

    setState(() => _activeError = _ErrorType.build);

    ErrorLogStore.instance.addEntry(ErrorLogEntry(
      errorType: 'Build Error',
      message: 'Widget build() threw an exception',
      timestamp: DateTime.now(),
      source: 'flutter',
    ));

    span.setStatus(SpanStatusCode.Error, 'Build error triggered');
    span.end();

    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _activeError = null);
    });
  }

  void _triggerOverflowError() {
    final span = FlutterOTel.tracer.startSpan('demo.flutter_error.overflow');
    span.setStringAttribute('error.type', 'overflow_error');
    span.setStringAttribute('safe_mode', _safeMode.toString());

    setState(() => _activeError = _ErrorType.overflow);

    ErrorLogStore.instance.addEntry(ErrorLogEntry(
      errorType: 'Overflow Error',
      message: 'Layout overflow triggered',
      timestamp: DateTime.now(),
      source: 'flutter',
    ));

    span.setStatus(SpanStatusCode.Error, 'Overflow error triggered');
    span.end();

    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _activeError = null);
    });
  }

  void _triggerAssertionError() {
    final span = FlutterOTel.tracer.startSpan('demo.flutter_error.assertion');
    span.setStringAttribute('error.type', 'assertion_error');

    try {
      assert(false, 'Demo assertion failure');
      // If assertions are stripped (release mode), report that.
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'Assertion',
        message: 'Assertions are stripped in release mode',
        timestamp: DateTime.now(),
        source: 'flutter',
      ));
      span.setStatus(SpanStatusCode.Unset, 'Assertions stripped');
    } catch (e, st) {
      FlutterOTel.reportError('flutter_error', e, st);
      ErrorLogStore.instance.addEntry(ErrorLogEntry(
        errorType: 'AssertionError',
        message: e.toString(),
        timestamp: DateTime.now(),
        source: 'flutter',
      ));
      span.setStatus(SpanStatusCode.Error, e.toString());
    } finally {
      span.end();
    }
  }

  void _triggerNullWidget() {
    final span = FlutterOTel.tracer.startSpan('demo.flutter_error.null_widget');
    span.setStringAttribute('error.type', 'null_widget');
    span.setStringAttribute('safe_mode', _safeMode.toString());

    setState(() => _activeError = _ErrorType.nullWidget);

    ErrorLogStore.instance.addEntry(ErrorLogEntry(
      errorType: 'Null Widget',
      message: 'Attempted to render a null widget scenario',
      timestamp: DateTime.now(),
      source: 'flutter',
    ));

    span.setStatus(SpanStatusCode.Error, 'Null widget triggered');
    span.end();

    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _activeError = null);
    });
  }

  Widget _buildErrorArea() {
    if (_activeError == null) {
      return const SizedBox.shrink();
    }

    switch (_activeError!) {
      case _ErrorType.build:
        if (_safeMode) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Build error caught (safe mode on). '
                    'Recovering automatically...',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
        return const _ThrowingWidget();

      case _ErrorType.overflow:
        if (_safeMode) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Overflow error caught (safe mode on). '
                    'Recovering automatically...',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          );
        }
        return Row(
          children: [
            Container(width: 10000, height: 50, color: Colors.red),
          ],
        );

      case _ErrorType.nullWidget:
        if (_safeMode) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.help, color: Colors.purple),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Null widget scenario caught (safe mode on). '
                    'Recovering automatically...',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ],
            ),
          );
        }
        return const _NullWidgetDemo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Safe Mode'),
            Switch(
              value: _safeMode,
              onChanged: (value) => setState(() => _safeMode = value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _triggerBuildError,
            child: const Text('Build Error'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _triggerOverflowError,
            child: const Text('Overflow Error'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _triggerAssertionError,
            child: const Text('Assertion Error'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _triggerNullWidget,
            child: const Text('Null Widget'),
          ),
        ),
        const SizedBox(height: 12),
        _buildErrorArea(),
      ],
    );
  }
}

enum _ErrorType { build, overflow, nullWidget }

class _ThrowingWidget extends StatelessWidget {
  const _ThrowingWidget();

  @override
  Widget build(BuildContext context) {
    throw Exception('Build error: widget threw during build');
  }
}

class _NullWidgetDemo extends StatelessWidget {
  const _NullWidgetDemo();

  @override
  Widget build(BuildContext context) {
    // Simulate a scenario where conditional logic fails to return a valid widget.
    final Widget? widget = null;
    // ignore: dead_code
    return widget ?? const Text('Fallback: null widget handled');
  }
}
