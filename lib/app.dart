import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';
import 'package:go_router/go_router.dart';

import 'screens/context_propagation_demo_screen.dart';
import 'screens/errors_page.dart';
import 'screens/interaction_demo_screen.dart';
import 'screens/lifecycle_demo_screen.dart';
import 'screens/main_screen.dart';
import 'screens/metrics_demo_screen.dart';
import 'screens/performance_demo_screen.dart';
import 'screens/resource_demo_screen.dart';
import 'screens/sampling_demo_screen.dart';
import 'screens/tracing_demo_screen.dart';

final _router = GoRouter(
  observers: [FlutterOTel.routeObserver],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/tracing',
      builder: (context, state) => const TracingDemoScreen(),
    ),
    GoRoute(
      path: '/metrics',
      builder: (context, state) => const MetricsDemoScreen(),
    ),
    GoRoute(
      path: '/lifecycle',
      builder: (context, state) => const LifecycleDemoScreen(),
    ),
    GoRoute(
      path: '/performance',
      builder: (context, state) => const PerformanceDemoScreen(),
    ),
    GoRoute(
      path: '/interactions',
      builder: (context, state) => const InteractionDemoScreen(),
    ),
    GoRoute(
      path: '/errors',
      builder: (context, state) => const ErrorsPage(),
    ),
    GoRoute(
      path: '/context',
      builder: (context, state) => const ContextPropagationDemoScreen(),
    ),
    GoRoute(
      path: '/resources',
      builder: (context, state) => const ResourceDemoScreen(),
    ),
    GoRoute(
      path: '/sampling',
      builder: (context, state) => const SamplingDemoScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dartastic Test App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}
