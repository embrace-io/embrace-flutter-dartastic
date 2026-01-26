import 'package:flutter/material.dart';

import 'screens/main_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dartastic Test App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Note: FlutterOTel.routeObserver disabled due to bug in flutterrific_opentelemetry v0.3.4
      // The package casts route.settings to Page on line 91, but MaterialApp uses RouteSettings
      // navigatorObservers: [FlutterOTel.routeObserver],
      home: const MainScreen(),
    );
  }
}
