import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'app.dart';

void main() {
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

    runApp(const MyApp());
  }, (error, stack) {
    FlutterOTel.reportError('Zone Error', error, stack);
  });
}
