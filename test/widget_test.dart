import 'package:flutter_test/flutter_test.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'package:embrace_flutter_dartastic/app.dart';

class NoOpSpanProcessor implements SpanProcessor {
  @override
  Future<void> onStart(Span span, Context? parentContext) async {}
  @override
  Future<void> onEnd(Span span) async {}
  @override
  Future<void> onNameUpdate(Span span, String newName) async {}
  @override
  Future<void> shutdown() async {}
  @override
  Future<void> forceFlush() async {}
}

void main() {
  setUpAll(() async {
    await FlutterOTel.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
      tracerName: 'test',
      detectPlatformResources: false,
      flushTracesInterval: null,
      enableMetrics: false,
      spanProcessor: NoOpSpanProcessor(),
    );
  });

  testWidgets('App renders with navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Errors'), findsOneWidget);
    expect(find.text('Dartastic Test'), findsOneWidget);
  });
}
