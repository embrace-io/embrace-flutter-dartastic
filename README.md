# Dartastic OpenTelemetry Demo App

A Flutter demonstration app showcasing the integration of [flutterrific_opentelemetry](https://pub.dev/packages/flutterrific_opentelemetry) and [dartastic_opentelemetry](https://pub.dev/packages/dartastic_opentelemetry) for OpenTelemetry instrumentation in Flutter applications.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Configuration](#configuration)
- [OpenTelemetry Collector Setup](#opentelemetry-collector-setup)
- [Demo Features](#demo-features)
- [Project Structure](#project-structure)
- [Running Tests](#running-tests)
- [Session Overview Script](#session-overview-script)
- [Version History](#version-history)

## Overview

This app serves as a comprehensive feature showcase with 10 demo areas covering the full breadth of OpenTelemetry capabilities in Flutter, including tracing, metrics, lifecycle monitoring, performance tracking, error handling, context propagation, and more. Each demo area is interactive and emits real telemetry data to a configurable OTel Collector.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.10.4)
- [Docker](https://www.docker.com/get-started/) (for running the OTel Collector)
- An Android emulator, iOS simulator, or physical device

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/embrace-io/embrace-flutter-dartastic.git
   cd embrace-flutter-dartastic
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Verify the setup:**

   ```bash
   flutter analyze
   flutter test
   ```

## Running the App

Start the app on a connected device or emulator:

```bash
flutter run
```

The app launches with a home screen grid displaying 10 demo areas. Tap any button to navigate into that demo and interact with the OpenTelemetry features.

> **Note:** The default endpoint targets the Android emulator. If you are running on a different platform, update the endpoint in `lib/config.dart` (see [Configuration](#configuration)).

## Configuration

OTel SDK settings (endpoint, service name, version, etc.) are centralized in `lib/config.dart`. Edit this file to match your environment.

The most common change is the **endpoint**:

| Platform | Endpoint |
|----------|----------|
| Android emulator | `http://10.0.2.2:4317` (default) |
| iOS simulator / desktop | `http://localhost:4317` |
| Physical device | `http://<host-LAN-IP>:4317` |

`10.0.2.2` is the Android emulator's alias for the host machine's localhost. On iOS simulator or desktop the app runs directly on the host, so plain `localhost` works.

## OpenTelemetry Collector Setup

The app sends traces, metrics, and logs to an OpenTelemetry Collector. A config file is included in the repository that sets up the collector with debug output so you can see all telemetry in the terminal.

### Starting the Collector

Run the following command from the project root:

```bash
docker run --rm \
  -p 4317:4317 \
  -p 4318:4318 \
  -v $(pwd)/otel-collector-config.yaml:/etc/otelcol/config.yaml \
  otel/opentelemetry-collector:latest
```

This starts the collector with:

- **Port 4317** - gRPC receiver (used by the app)
- **Port 4318** - HTTP receiver
- **Debug exporter** - prints all received telemetry (traces, metrics, logs) to the console with detailed verbosity

### Collector Configuration

The included `otel-collector-config.yaml` defines three pipelines:

| Pipeline | Receiver | Exporter |
|----------|----------|----------|
| Traces   | OTLP     | Debug    |
| Metrics  | OTLP     | Debug    |
| Logs     | OTLP     | Debug    |

To forward telemetry to a backend (e.g., Jaeger, Prometheus, or Embrace), add the appropriate exporter to the config file. See the [OpenTelemetry Collector docs](https://opentelemetry.io/docs/collector/) for details.

### Verifying the Connection

1. Start the collector (see above).
2. Launch the app on an Android emulator with `flutter run`.
3. Interact with any demo screen.
4. Observe telemetry output in the collector's terminal.

## Demo Features

| # | Demo | Description |
|---|------|-------------|
| 1 | **Tracing Demo** | Manual span creation, nested spans, span events, and span status codes |
| 2 | **Metrics Demo** | Counter and histogram metrics with real-time updates |
| 3 | **Lifecycle Demo** | App lifecycle monitoring including cold/warm starts and foreground sessions |
| 4 | **Performance Demo** | Frame rate tracking, rendering metrics, and jank detection |
| 5 | **Interactions Demo** | Widget interaction tracking with detailed character and position tracing |
| 6 | **Errors Demo** | Error types including sync errors, async errors, Flutter errors, and contextual errors |
| 7 | **Context Demo** | Context propagation across async chains, callbacks, and isolates |
| 8 | **Resources Demo** | Display and inspection of OTel resource attributes |
| 9 | **Sampling Demo** | Sampling configuration and strategies |
| 10 | **Baggage Demo** | Baggage propagation for passing key-value pairs across service boundaries |

## Project Structure

```
lib/
  main.dart                  # Entry point with OTel SDK initialization
  config.dart                # OTel SDK configuration (endpoint, service name, etc.)
  app.dart                   # App widget and router configuration
  screens/
    home_page.dart           # Home grid with navigation to all demos
    main_screen.dart         # Bottom navigation shell (Home + Errors tabs)
    tracing_demo_screen.dart
    metrics_demo_screen.dart
    lifecycle_demo_screen.dart
    lifecycle_demo/           # Lifecycle tracking helpers
    performance_demo_screen.dart
    performance_demo/         # Frame rate and jank detection helpers
    interaction_demo_screen.dart
    errors_page.dart
    context_propagation_demo_screen.dart
    resource_demo_screen.dart
    sampling_demo_screen.dart
    baggage_demo_screen.dart
test/                        # Widget and unit tests mirroring feature structure
scripts/
  otel_session_overview.py   # Parses collector output into a session summary
otel-collector-config.yaml   # OTel Collector configuration
```

## Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run the linter
flutter analyze
```

## Session Overview Script

A Python script is included to parse the OTel Collector's debug output and display an organized session summary grouped by demo area.

```bash
# From a saved log file
python3 scripts/otel_session_overview.py collector_output.log

# From a running collector (piped)
docker logs <container_id> 2>&1 | python3 scripts/otel_session_overview.py
```

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2026-02-09 | Initial release with all 10 demo areas: tracing, metrics, lifecycle monitoring, performance tracking, widget interaction tracking, error types, context propagation, resource attributes, sampling configuration, and baggage propagation |
