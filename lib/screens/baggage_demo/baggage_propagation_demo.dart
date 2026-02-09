import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';
import 'package:http/http.dart' as http;

class BaggagePropagationDemo extends StatefulWidget {
  const BaggagePropagationDemo({
    super.key,
    required this.baggage,
  });

  final Baggage baggage;

  @override
  State<BaggagePropagationDemo> createState() =>
      _BaggagePropagationDemoState();
}

class _BaggagePropagationDemoState extends State<BaggagePropagationDemo> {
  bool _isLoading = false;
  String? _rawHeader;
  Map<String, dynamic>? _echoedHeaders;
  String? _traceId;
  String? _error;

  String _buildBaggageHeader() {
    final entries = widget.baggage.getAllEntries();
    return entries.entries.map((e) {
      final base = '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.value)}';
      if (e.value.metadata != null && e.value.metadata!.isNotEmpty) {
        return '$base;${e.value.metadata}';
      }
      return base;
    }).join(',');
  }

  Future<void> _makeRequestWithBaggage() async {
    if (widget.baggage.isEmpty) return;

    setState(() {
      _isLoading = true;
      _rawHeader = null;
      _echoedHeaders = null;
      _traceId = null;
      _error = null;
    });

    final span = FlutterOTel.tracer.startSpan(
      'baggage.http_request',
      kind: SpanKind.client,
    );

    // Add baggage entries as span attributes
    final allEntries = widget.baggage.getAllEntries();
    for (final entry in allEntries.entries) {
      span.setStringAttribute('baggage.${entry.key}', entry.value.value);
    }

    final baggageHeader = _buildBaggageHeader();
    final headers = <String, String>{
      'baggage': baggageHeader,
    };

    setState(() {
      _rawHeader = baggageHeader;
      _traceId = span.spanContext.traceId.toString();
    });

    try {
      final response = await http.get(
        Uri.parse('https://httpbin.org/headers'),
        headers: headers,
      );

      span.setIntAttribute('http.status_code', response.statusCode);
      span.setStatus(SpanStatusCode.Ok);
      span.end();

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      setState(() {
        _isLoading = false;
        _echoedHeaders = body['headers'] as Map<String, dynamic>?;
      });
    } catch (e) {
      span.setStatus(SpanStatusCode.Error, e.toString());
      span.end();

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
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
                _isLoading || widget.baggage.isEmpty ? null : _makeRequestWithBaggage,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Make Request with Baggage'),
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
        if (_rawHeader != null) ...[
          const SizedBox(height: 16),
          Text(
            'Baggage Header Sent',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _rawHeader!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trace ID: $_traceId',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ],
        if (_echoedHeaders != null) ...[
          const SizedBox(height: 12),
          Text(
            'Echoed Response Headers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          ..._echoedHeaders!.entries.map(
            (entry) => Text(
              '${entry.key}: ${entry.value}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network error (the header that would have been sent is shown above)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade800,
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'W3C Baggage Header Format',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'key1=value1,key2=value2;metadata',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Baggage entries are comma-separated. Each entry has a key=value pair, '
          'optionally followed by semicolon-delimited metadata properties.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
