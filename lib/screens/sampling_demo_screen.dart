import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'metrics_demo/demo_section.dart';
import 'sampling_demo/parent_based_sampler_demo.dart';
import 'sampling_demo/probability_sampler_demo.dart';
import 'sampling_demo/rate_limiting_sampler_demo.dart';
import 'sampling_demo/sampler_selector.dart';
import 'sampling_demo/sampler_type.dart';
import 'sampling_demo/sampling_statistics.dart';
import 'sampling_demo/statistics_panel.dart';

class SamplingDemoScreen extends StatefulWidget {
  const SamplingDemoScreen({super.key});

  @override
  State<SamplingDemoScreen> createState() => _SamplingDemoScreenState();
}

class _SamplingDemoScreenState extends State<SamplingDemoScreen> {
  SamplerType _selectedSamplerType = SamplerType.alwaysOn;
  double _ratio = 0.5;
  double _spansPerSecond = 10.0;

  void _onSamplerChanged(SamplerType type) {
    setState(() {
      _selectedSamplerType = type;
    });
    _updateSampler();
  }

  void _updateSampler() {
    final sampler = createSampler(
      _selectedSamplerType,
      ratio: _ratio,
      spansPerSecond: _spansPerSecond,
    );
    FlutterOTel.tracerProvider.sampler = sampler;
  }

  void _onRatioChanged(double ratio) {
    setState(() {
      _ratio = ratio;
    });
    _updateSampler();
  }

  void _onRateChanged(double rate) {
    setState(() {
      _spansPerSecond = rate;
    });
    _updateSampler();
  }

  void _generateTestSpan() {
    final span = FlutterOTel.tracer.startSpan('sampling.test_span');
    final wasSampled = span.isRecording;
    span.end();
    SamplingStatistics.instance.recordSpan(wasSampled: wasSampled);
  }

  Widget? _buildSamplerDemo() {
    switch (_selectedSamplerType) {
      case SamplerType.traceIdRatio:
        return DemoSection(
          title: 'Probability Sampling',
          description: 'Adjust the sampling ratio and observe the results.',
          child: ProbabilitySamplerDemo(
            ratio: _ratio,
            onRatioChanged: _onRatioChanged,
          ),
        );
      case SamplerType.rateLimiting:
        return DemoSection(
          title: 'Rate Limiting',
          description: 'Configure the rate limit and burst spans to test it.',
          child: RateLimitingSamplerDemo(
            spansPerSecond: _spansPerSecond,
            onRateChanged: _onRateChanged,
          ),
        );
      case SamplerType.parentBased:
        return DemoSection(
          title: 'Parent-Based Sampling',
          description:
              'See how child spans inherit sampling decisions from parents.',
          child: const ParentBasedSamplerDemo(),
        );
      case SamplerType.alwaysOn:
      case SamplerType.alwaysOff:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final samplerDemo = _buildSamplerDemo();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sampling Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DemoSection(
            title: 'Current Sampler',
            description: 'Select a sampler to control which spans are recorded.',
            child: SamplerSelector(
              selectedType: _selectedSamplerType,
              onChanged: _onSamplerChanged,
            ),
          ),
          const SizedBox(height: 16),
          if (samplerDemo != null) ...[
            samplerDemo,
            const SizedBox(height: 16),
          ],
          DemoSection(
            title: 'Sampling Statistics',
            description: 'Track how many spans are sampled vs dropped.',
            child: const StatisticsPanel(),
          ),
          const SizedBox(height: 16),
          DemoSection(
            title: 'Test Sampling',
            description: 'Generate test spans to see sampling in action.',
            child: Center(
              child: ElevatedButton(
                onPressed: _generateTestSpan,
                child: const Text('Generate Test Span'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sampling changes only affect new spans. '
                      'Spans that are already in progress will not be affected.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
