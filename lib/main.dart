import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'app.dart';
import 'screens/lifecycle_demo/foreground_tracker.dart';
import 'screens/lifecycle_demo/launch_tracker.dart';
import 'screens/lifecycle_demo/lifecycle_metrics.dart';

void main() {
  final mainStartTime = DateTime.now();
  LaunchTracker.instance.recordMainStart(mainStartTime);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterOTel.reportError(
      'FlutterError.onError',
      details.exception,
      details.stack,
    );
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await FlutterOTel.initialize(
      serviceName: 'embrace-flutter-dartastic',
      serviceVersion: '1.0.0',
      tracerName: 'main',
      resourceAttributes: {
        'deployment.environment': 'development',
        'service.namespace': 'testing',
      }.toAttributes(),
    );

    LifecycleMetrics.instance.initialize();
    LaunchTracker.instance.initialize();
    ForegroundTracker.instance.initialize();

    runApp(const MyApp());
  }, (error, stack) {
    FlutterOTel.reportError('Zone Error', error, stack);
  });
}
