import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

enum SamplerType {
  alwaysOn(
    displayName: 'Always On',
    description: 'Samples every span. All telemetry data is recorded.',
  ),
  alwaysOff(
    displayName: 'Always Off',
    description: 'Drops every span. No telemetry data is recorded.',
  ),
  traceIdRatio(
    displayName: 'Trace ID Ratio',
    description:
        'Samples a percentage of traces based on trace ID. Default: 50%.',
  ),
  rateLimiting(
    displayName: 'Rate Limiting',
    description:
        'Limits the number of sampled spans per second. Default: 10/sec.',
  ),
  parentBased(
    displayName: 'Parent Based',
    description:
        'Defers sampling decision to the parent span. Root spans use Always On.',
  );

  const SamplerType({required this.displayName, required this.description});

  final String displayName;
  final String description;
}

Sampler createSampler(SamplerType type) {
  switch (type) {
    case SamplerType.alwaysOn:
      return AlwaysOnSampler();
    case SamplerType.alwaysOff:
      return AlwaysOffSampler();
    case SamplerType.traceIdRatio:
      return TraceIdRatioSampler(0.5);
    case SamplerType.rateLimiting:
      return RateLimitingSampler(10.0);
    case SamplerType.parentBased:
      return ParentBasedSampler(AlwaysOnSampler());
  }
}
