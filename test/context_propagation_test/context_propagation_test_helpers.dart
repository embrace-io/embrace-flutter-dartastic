import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'package:embrace_flutter_dartastic/screens/context_propagation_demo_screen.dart';

/// A no-op span processor for tests to avoid gRPC connection errors.
class NoOpSpanProcessor implements SpanProcessor {
  @override
  Future<void> onStart(Span span, Context? parentContext) async {}
  @override
  Future<void> onEnd(Span span) async {}
  @override
  Future<void> onNameUpdate(Span span, String newName) async {}
  @override
  Future<void> shutdown() async {}
  @override
  Future<void> forceFlush() async {}
}

Future<void> initializeOTelForTests() async {
  await FlutterOTel.initialize(
    endpoint: 'http://localhost:4317',
    serviceName: 'test-service',
    serviceVersion: '1.0.0',
    tracerName: 'test',
    detectPlatformResources: false,
    flushTracesInterval: null,
    enableMetrics: false,
    spanProcessor: NoOpSpanProcessor(),
  );
}

Widget buildContextPropagationTestWidget() {
  return const MaterialApp(
    home: ContextPropagationDemoScreen(),
  );
}
