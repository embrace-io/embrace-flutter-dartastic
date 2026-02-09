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
        'Defers sampling decision to the parent span. Root spans use probability sampling.',
  );

  const SamplerType({required this.displayName, required this.description});

  final String displayName;
  final String description;
}

Sampler createSampler(
  SamplerType type, {
  double ratio = 0.5,
  double spansPerSecond = 10.0,
}) {
  switch (type) {
    case SamplerType.alwaysOn:
      return AlwaysOnSampler();
    case SamplerType.alwaysOff:
      return AlwaysOffSampler();
    case SamplerType.traceIdRatio:
      return TraceIdRatioSampler(ratio);
    case SamplerType.rateLimiting:
      return RateLimitingSampler(spansPerSecond);
    case SamplerType.parentBased:
      return ParentBasedSampler(TraceIdRatioSampler(ratio));
  }
}
