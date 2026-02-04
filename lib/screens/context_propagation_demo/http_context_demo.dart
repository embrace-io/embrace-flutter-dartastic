import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';
import 'package:http/http.dart' as http;

class HttpContextDemo extends StatefulWidget {
  const HttpContextDemo({super.key});

  @override
  State<HttpContextDemo> createState() => _HttpContextDemoState();
}

class _HttpContextDemoState extends State<HttpContextDemo> {
  bool _isLoading = false;
  Map<String, String>? _outgoingHeaders;
  Map<String, dynamic>? _echoedHeaders;
  String? _traceId;
  String? _spanId;
  int? _statusCode;
  String? _error;

  /// Build W3C traceparent header: version-traceId-spanId-traceFlags
  /// See https://www.w3.org/TR/trace-context/
  Map<String, String> _buildTraceContextHeaders(SpanContext spanContext) {
    final traceId = spanContext.traceId.hexString;
    final spanId = spanContext.spanId.hexString;
    final traceFlags = spanContext.traceFlags.toString();

    final headers = <String, String>{
      'traceparent': '00-$traceId-$spanId-$traceFlags',
    };

    final traceState = spanContext.traceState;
    if (traceState != null && traceState.entries.isNotEmpty) {
      final value = traceState.entries.entries
          .map((e) => '${e.key}=${e.value}')
          .join(',');
      headers['tracestate'] = value;
    }

    return headers;
  }

  Future<void> _makeTracedRequest() async {
    setState(() {
      _isLoading = true;
      _outgoingHeaders = null;
      _echoedHeaders = null;
      _traceId = null;
      _spanId = null;
      _statusCode = null;
      _error = null;
    });

    final span = FlutterOTel.tracer.startSpan(
      'http.request',
      kind: SpanKind.client,
    );

    span.setStringAttribute('http.method', 'GET');
    span.setStringAttribute('http.url', 'https://httpbin.org/headers');

    // Build W3C Trace Context headers from span context
    final headers = _buildTraceContextHeaders(span.spanContext);

    setState(() {
      _outgoingHeaders = Map.from(headers);
      _traceId = span.spanContext.traceId.toString();
      _spanId = span.spanContext.spanId.toString();
    });

    try {
      final response = await http.get(
        Uri.parse('https://httpbin.org/headers'),
        headers: headers,
      );

      span.setIntAttribute('http.status_code', response.statusCode);
      span.setIntAttribute(
          'http.response_content_length', response.contentLength ?? 0);
      span.setStatus(SpanStatusCode.Ok);
      span.end();

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      setState(() {
        _isLoading = false;
        _statusCode = response.statusCode;
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
            onPressed: _isLoading ? null : _makeTracedRequest,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Make Traced Request'),
          ),
        ),
        if (_outgoingHeaders != null) ...[
          const SizedBox(height: 16),
          Text(
            'Span Info',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
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
          if (_statusCode != null)
            Text(
              'Status Code: $_statusCode',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          const SizedBox(height: 12),
          Text(
            'Outgoing Headers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          ..._outgoingHeaders!.entries.map(
            (entry) => Text(
              '${entry.key}: ${entry.value}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
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
                  'Network error (headers that would have been sent are shown above)',
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
      ],
    );
  }
}
