import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/resource_demo/sdk_resources_demo.dart';

import 'resource_test_helpers.dart';

Widget _buildSdkResourcesWidget(Map<String, String> attributes) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SdkResourcesDemo(attributes: attributes),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('SdkResourcesDemo', () {
    testWidgets('displays all expected SDK attribute keys', (tester) async {
      await tester.pumpWidget(_buildSdkResourcesWidget({}));

      expect(find.text('telemetry.sdk.name'), findsOneWidget);
      expect(find.text('telemetry.sdk.version'), findsOneWidget);
      expect(find.text('telemetry.sdk.language'), findsOneWidget);
      expect(find.text('webengine.name'), findsOneWidget);
      expect(find.text('webengine.version'), findsOneWidget);
    });

    testWidgets('displays attribute values when present', (tester) async {
      await tester.pumpWidget(_buildSdkResourcesWidget({
        'telemetry.sdk.name': 'dartastic_opentelemetry',
        'telemetry.sdk.version': '0.9.3',
        'telemetry.sdk.language': 'dart',
      }));

      expect(find.text('dartastic_opentelemetry'), findsOneWidget);
      expect(find.text('0.9.3'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
    });

    testWidgets('shows Not available for missing attributes', (tester) async {
      await tester.pumpWidget(_buildSdkResourcesWidget({}));

      expect(find.text('Not available'), findsNWidgets(5));
    });

    testWidgets('displays SDK documentation note', (tester) async {
      await tester.pumpWidget(_buildSdkResourcesWidget({}));

      expect(
        find.text(
          'See dartastic_opentelemetry on pub.dev for SDK documentation.',
        ),
        findsOneWidget,
      );
    });
  });
}
