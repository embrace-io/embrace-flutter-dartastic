import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'sampling_statistics.dart';

class ParentBasedSamplerDemo extends StatefulWidget {
  const ParentBasedSamplerDemo({super.key});

  @override
  State<ParentBasedSamplerDemo> createState() => _ParentBasedSamplerDemoState();
}

class _SpanTreeEntry {
  const _SpanTreeEntry({
    required this.name,
    required this.wasSampled,
    required this.indent,
  });

  final String name;
  final bool wasSampled;
  final int indent;
}

class _ParentBasedSamplerDemoState extends State<ParentBasedSamplerDemo> {
  List<_SpanTreeEntry>? _treeEntries;

  void _createSampledParent() {
    final previousSampler = FlutterOTel.tracerProvider.sampler;

    // Force parent to be sampled via AlwaysOnSampler
    FlutterOTel.tracerProvider.sampler = AlwaysOnSampler();
    final parentSpan =
        FlutterOTel.tracer.startSpan('sampling.parent_sampled');
    final parentSampled = parentSpan.isRecording;

    // Restore ParentBasedSampler for children
    FlutterOTel.tracerProvider.sampler = previousSampler;

    final child1 = FlutterOTel.tracer.startSpan(
      'sampling.child_1',
      parentSpan: parentSpan,
    );
    final child1Sampled = child1.isRecording;

    final child2 = FlutterOTel.tracer.startSpan(
      'sampling.child_2',
      parentSpan: parentSpan,
    );
    final child2Sampled = child2.isRecording;

    child2.end();
    child1.end();
    parentSpan.end();

    SamplingStatistics.instance.recordSpan(wasSampled: parentSampled);
    SamplingStatistics.instance.recordSpan(wasSampled: child1Sampled);
    SamplingStatistics.instance.recordSpan(wasSampled: child2Sampled);

    setState(() {
      _treeEntries = [
        _SpanTreeEntry(
          name: 'parent (sampled)',
          wasSampled: parentSampled,
          indent: 0,
        ),
        _SpanTreeEntry(
          name: 'child_1',
          wasSampled: child1Sampled,
          indent: 1,
        ),
        _SpanTreeEntry(
          name: 'child_2',
          wasSampled: child2Sampled,
          indent: 1,
        ),
      ];
    });
  }

  void _createUnsampledParent() {
    final previousSampler = FlutterOTel.tracerProvider.sampler;

    // Force parent to be dropped via AlwaysOffSampler
    FlutterOTel.tracerProvider.sampler = AlwaysOffSampler();
    final parentSpan =
        FlutterOTel.tracer.startSpan('sampling.parent_unsampled');
    final parentSampled = parentSpan.isRecording;

    // Restore ParentBasedSampler for children
    FlutterOTel.tracerProvider.sampler = previousSampler;

    final child1 = FlutterOTel.tracer.startSpan(
      'sampling.child_1',
      parentSpan: parentSpan,
    );
    final child1Sampled = child1.isRecording;

    final child2 = FlutterOTel.tracer.startSpan(
      'sampling.child_2',
      parentSpan: parentSpan,
    );
    final child2Sampled = child2.isRecording;

    child2.end();
    child1.end();
    parentSpan.end();

    SamplingStatistics.instance.recordSpan(wasSampled: parentSampled);
    SamplingStatistics.instance.recordSpan(wasSampled: child1Sampled);
    SamplingStatistics.instance.recordSpan(wasSampled: child2Sampled);

    setState(() {
      _treeEntries = [
        _SpanTreeEntry(
          name: 'parent (unsampled)',
          wasSampled: parentSampled,
          indent: 0,
        ),
        _SpanTreeEntry(
          name: 'child_1',
          wasSampled: child1Sampled,
          indent: 1,
        ),
        _SpanTreeEntry(
          name: 'child_2',
          wasSampled: child2Sampled,
          indent: 1,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parent-Based Sampling',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _createSampledParent,
                child: const Text('Create Sampled Parent'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _createUnsampledParent,
                child: const Text('Create Unsampled Parent'),
              ),
            ),
          ],
        ),
        if (_treeEntries != null) ...[
          const SizedBox(height: 16),
          ..._treeEntries!.map((entry) => _SpanTreeItem(entry: entry)),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Parent-based sampling inherits the sampling decision '
                    'from the parent span. If the parent is sampled, children '
                    'are sampled too. For remote parents, the same logic '
                    'applies using the remote span context.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpanTreeItem extends StatelessWidget {
  const _SpanTreeItem({required this.entry});

  final _SpanTreeEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: entry.indent * 24.0, top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: 3,
              color: entry.wasSampled ? Colors.green : Colors.red,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Icon(
                entry.wasSampled ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: entry.wasSampled ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                entry.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.wasSampled ? 'Sampled' : 'Dropped',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: entry.wasSampled ? Colors.green : Colors.red,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
