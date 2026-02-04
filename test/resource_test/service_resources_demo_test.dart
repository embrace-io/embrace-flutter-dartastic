import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/resource_demo/service_resources_demo.dart';

import 'resource_test_helpers.dart';

Widget _buildServiceResourcesWidget(Map<String, String> attributes) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ServiceResourcesDemo(attributes: attributes),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('ServiceResourcesDemo', () {
    testWidgets('displays all expected service attribute keys', (tester) async {
      await tester.pumpWidget(_buildServiceResourcesWidget({
        'service.name': 'test-service',
        'service.version': '1.0.0',
        'service.namespace': 'test-namespace',
        'service.instance.id': 'abc-123',
        'deployment.environment': 'testing',
      }));

      expect(find.text('service.name'), findsOneWidget);
      expect(find.text('service.version'), findsOneWidget);
      expect(find.text('service.namespace'), findsOneWidget);
      expect(find.text('service.instance.id'), findsOneWidget);
      expect(find.text('deployment.environment'), findsOneWidget);
    });

    testWidgets('displays attribute values', (tester) async {
      await tester.pumpWidget(_buildServiceResourcesWidget({
        'service.name': 'test-service',
        'service.version': '1.0.0',
      }));

      expect(find.text('test-service'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('shows configured label for service.name', (tester) async {
      await tester.pumpWidget(_buildServiceResourcesWidget({
        'service.name': 'test-service',
      }));

      expect(find.text('configured'), findsOneWidget);
    });

    testWidgets('shows auto-detected label for service.instance.id',
        (tester) async {
      await tester.pumpWidget(_buildServiceResourcesWidget({
        'service.instance.id': 'abc-123',
      }));

      expect(find.text('auto-detected'), findsOneWidget);
    });

    testWidgets('shows Not configured for missing keys', (tester) async {
      await tester.pumpWidget(_buildServiceResourcesWidget({}));

      expect(find.text('Not configured'), findsWidgets);
    });

    testWidgets('displays initialization note', (tester) async {
      await tester.pumpWidget(_buildServiceResourcesWidget({}));

      expect(
        find.text('These attributes are set in FlutterOTel.initialize().'),
        findsOneWidget,
      );
    });
  });
}
