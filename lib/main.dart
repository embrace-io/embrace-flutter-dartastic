import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'app.dart';
import 'config.dart';
import 'screens/lifecycle_demo/foreground_tracker.dart';
import 'screens/lifecycle_demo/launch_tracker.dart';
import 'screens/lifecycle_demo/lifecycle_metrics.dart';
import 'screens/performance_demo/frame_metrics_exporter.dart';
import 'screens/performance_demo/frame_rate_tracker.dart';
import 'screens/performance_demo/jank_detector.dart';

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
      serviceName: OTelConfig.serviceName,
      serviceVersion: OTelConfig.serviceVersion,
      tracerName: OTelConfig.tracerName,
      endpoint: OTelConfig.endpoint,
      secure: OTelConfig.secure,
      resourceAttributes: {
        'deployment.environment': OTelConfig.deploymentEnvironment,
        'service.namespace': OTelConfig.serviceNamespace,
      }.toAttributes(),
    );

    LifecycleMetrics.instance.initialize();
    LaunchTracker.instance.initialize();
    ForegroundTracker.instance.initialize();
    JankDetector.instance.initialize();
    FrameMetricsExporter.instance.initialize();
    FrameRateTracker.instance.start();

    runApp(const MyApp());
  }, (error, stack) {
    FlutterOTel.reportError('Zone Error', error, stack);
  });
}
