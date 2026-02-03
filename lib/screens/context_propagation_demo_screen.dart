import 'package:flutter/material.dart';

import 'context_propagation_demo/async_await_context_demo.dart';
import 'context_propagation_demo/current_context_panel.dart';
import 'context_propagation_demo/future_then_context_demo.dart';
import 'context_propagation_demo/http_context_demo.dart';
import 'context_propagation_demo/isolate_context_demo.dart';
import 'metrics_demo/demo_section.dart';

class ContextPropagationDemoScreen extends StatelessWidget {
  const ContextPropagationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Context Propagation Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          DemoSection(
            title: 'Current Context',
            description: 'Live view of the active trace context. The trace ID '
                'and span ID update when spans are active.',
            child: CurrentContextPanel(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Async/Await Context',
            description: 'Context propagation through async/await chains. '
                'All child spans share the same trace ID as the parent '
                'when using explicit parentSpan references.',
            child: AsyncAwaitContextDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Future.then Callbacks',
            description: 'Compares correct vs incorrect context propagation '
                'in Future.then() callback chains. Without explicit parent '
                'references, each callback creates spans in separate traces.',
            child: FutureThenContextDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'Isolate Context',
            description: 'Context propagation across isolate boundaries. '
                'Uses Context.runIsolate() to serialize and deserialize '
                'the trace context into a compute isolate.',
            child: IsolateContextDemo(),
          ),
          SizedBox(height: 16),
          DemoSection(
            title: 'HTTP Context Propagation',
            description: 'Injects W3C Trace Context headers (traceparent, '
                'tracestate) into HTTP requests for distributed tracing. '
                'Uses httpbin.org to echo back the injected headers.',
            child: HttpContextDemo(),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
