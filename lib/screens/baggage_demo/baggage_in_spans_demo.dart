import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

class BaggageInSpansDemo extends StatefulWidget {
  const BaggageInSpansDemo({
    super.key,
    required this.baggage,
  });

  final Baggage baggage;

  @override
  State<BaggageInSpansDemo> createState() => _BaggageInSpansDemoState();
}

class _BaggageInSpansDemoState extends State<BaggageInSpansDemo> {
  bool _autoCopy = false;
  String? _spanName;
  String? _traceId;
  String? _spanId;
  Map<String, String>? _baggageAttributes;

  void _createSpanWithBaggage() {
    final span = FlutterOTel.tracer.startSpan('baggage.demo_span');

    final attributes = <String, String>{};
    final entries = widget.baggage.getAllEntries();
    for (final entry in entries.entries) {
      final attrKey = 'baggage.${entry.key}';
      span.setStringAttribute(attrKey, entry.value.value);
      attributes[attrKey] = entry.value.value;
    }

    setState(() {
      _spanName = 'baggage.demo_span';
      _traceId = span.spanContext.traceId.toString();
      _spanId = span.spanContext.spanId.toString();
      _baggageAttributes = attributes;
    });

    span.end();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                widget.baggage.isEmpty ? null : _createSpanWithBaggage,
            child: const Text('Create Span with Baggage'),
          ),
        ),
        if (widget.baggage.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Add baggage entries above first.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
        if (_spanName != null) ...[
          const SizedBox(height: 16),
          Text(
            'Span Details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Name: $_spanName',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          Text(
            'Trace ID: $_traceId',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          Text(
            'Span ID: $_spanId',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          if (_baggageAttributes != null && _baggageAttributes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Baggage Attributes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            ..._baggageAttributes!.entries.map(
              (attr) => Text(
                '${attr.key} = ${attr.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ],
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Switch(
              value: _autoCopy,
              onChanged: (value) {
                setState(() {
                  _autoCopy = value;
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Auto-copy baggage to all spans',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Common Patterns',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'user_id \u2192 Correlate spans to a specific user\n'
          'tenant_id \u2192 Multi-tenant service routing\n'
          'request_id \u2192 End-to-end request tracking',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use baggage for cross-service context that all services need. '
          'Use span attributes for data relevant only to the current service.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}
