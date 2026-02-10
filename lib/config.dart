/// Centralized configuration for the OTel SDK.
///
/// Edit these values to match your target environment. The defaults are
/// configured for an Android emulator talking to a collector on the host.
class OTelConfig {
  OTelConfig._();

  /// The OTLP gRPC endpoint for the OTel Collector.
  ///
  /// Common values:
  /// - `http://10.0.2.2:4317` — Android emulator (maps to host localhost)
  /// - `http://localhost:4317`  — iOS simulator or desktop
  /// - `http://<device-ip>:4317` — physical device (use host machine's LAN IP)
  static const String endpoint = 'http://10.0.2.2:4317';

  /// Whether to use a secure (TLS) connection to the collector.
  static const bool secure = false;

  /// The logical service name reported in telemetry.
  static const String serviceName = 'embrace-flutter-dartastic';

  /// The service version reported in telemetry.
  static const String serviceVersion = '1.0.0';

  /// The tracer / instrumentation scope name.
  static const String tracerName = 'main';

  /// The deployment environment resource attribute.
  static const String deploymentEnvironment = 'development';

  /// The service namespace resource attribute.
  static const String serviceNamespace = 'testing';
}
