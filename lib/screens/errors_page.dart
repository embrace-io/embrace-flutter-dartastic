import 'package:flutter/material.dart';

import 'error_types_demo/async_error_demo.dart';
import 'error_types_demo/error_log_panel.dart';
import 'error_types_demo/error_with_context_demo.dart';
import 'error_types_demo/flutter_error_demo.dart';
import 'error_types_demo/sync_error_demo.dart';
import 'metrics_demo/demo_section.dart';

class ErrorsPage extends StatelessWidget {
  const ErrorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Error Types Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          DemoSection(
            title: 'Synchronous Errors',
            description: 'Throw and catch synchronous exceptions. Each button '
                'creates a span, catches the error, and reports it via OTel.',
            child: SyncErrorDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Async Errors',
            description: 'Demonstrate async error patterns including '
                'Future.error, async/await exceptions, Stream errors, '
                'and zone-caught uncaught async errors.',
            child: AsyncErrorDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Flutter Errors',
            description: 'Trigger Flutter framework errors like build '
                'failures, layout overflow, assertions, and null widgets. '
                'Toggle safe mode to control error recovery.',
            child: FlutterErrorDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Error with Context',
            description: 'Attach user context and breadcrumbs to error '
                'reports. Recent error log entries are included as span events.',
            child: ErrorWithContextDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Error Log',
            description: 'Real-time log of all errors triggered from the '
                'demo sections above.',
            child: ErrorLogPanel(),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
