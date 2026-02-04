import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/screens/resource_demo/platform_resources_demo.dart';

import 'resource_test_helpers.dart';

Widget _buildPlatformResourcesWidget(Map<String, String> attributes) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PlatformResourcesDemo(attributes: attributes),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeOTelForTests();
  });

  group('PlatformResourcesDemo', () {
    testWidgets('displays all expected platform attribute keys',
        (tester) async {
      await tester.pumpWidget(_buildPlatformResourcesWidget({}));

      expect(find.text('os.type'), findsOneWidget);
      expect(find.text('os.version'), findsOneWidget);
      expect(find.text('os.description'), findsOneWidget);
      expect(find.text('host.arch'), findsOneWidget);
      expect(find.text('host.name'), findsOneWidget);
      expect(find.text('device.model.name'), findsOneWidget);
      expect(find.text('device.manufacturer'), findsOneWidget);
    });

    testWidgets('shows Not available for missing platform attributes',
        (tester) async {
      await tester.pumpWidget(_buildPlatformResourcesWidget({}));

      // With detectPlatformResources: false, all should show not available
      expect(
        find.text('Not available on this platform'),
        findsNWidgets(7),
      );
    });

    testWidgets('displays present attribute values', (tester) async {
      await tester.pumpWidget(_buildPlatformResourcesWidget({
        'os.type': 'darwin',
        'os.version': '14.0',
      }));

      expect(find.text('darwin'), findsOneWidget);
      expect(find.text('14.0'), findsOneWidget);
    });

    testWidgets('shows Not available only for missing attributes',
        (tester) async {
      await tester.pumpWidget(_buildPlatformResourcesWidget({
        'os.type': 'darwin',
      }));

      // Only 6 should show not available (7 total minus 1 present)
      expect(
        find.text('Not available on this platform'),
        findsNWidgets(6),
      );
    });
  });
}
