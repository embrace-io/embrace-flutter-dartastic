import 'dart:convert';

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'metrics_demo/demo_section.dart';
import 'resource_demo/custom_resource_demo.dart';
import 'resource_demo/platform_resources_demo.dart';
import 'resource_demo/sdk_resources_demo.dart';
import 'resource_demo/service_resources_demo.dart';

class ResourceDemoScreen extends StatefulWidget {
  const ResourceDemoScreen({super.key});

  @override
  State<ResourceDemoScreen> createState() => _ResourceDemoScreenState();
}

class _ResourceDemoScreenState extends State<ResourceDemoScreen> {
  Map<String, String> _attributes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttributes();
  }

  void _loadAttributes() {
    setState(() => _isLoading = true);

    final resource = OTel.defaultResource;
    final attrs = resource?.attributes.toList() ?? [];
    final map = <String, String>{};
    for (final attr in attrs) {
      map[attr.key] = attr.value.toString();
    }

    setState(() {
      _attributes = map;
      _isLoading = false;
    });
  }

  void _copyAll() {
    final json = const JsonEncoder.withIndent('  ').convert(_attributes);
    Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource attributes copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Resources Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadAttributes,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy All',
            onPressed: _copyAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                DemoSection(
                  title: 'Service Resources',
                  description:
                      'Attributes identifying the service, version, and deployment.',
                  child: ServiceResourcesDemo(attributes: _attributes),
                ),
                const SizedBox(height: 16),
                DemoSection(
                  title: 'Platform Resources',
                  description:
                      'Automatically detected platform, OS, and device attributes.',
                  child: PlatformResourcesDemo(attributes: _attributes),
                ),
                const SizedBox(height: 16),
                DemoSection(
                  title: 'SDK Resources',
                  description:
                      'Attributes describing the OpenTelemetry SDK in use.',
                  child: SdkResourcesDemo(attributes: _attributes),
                ),
                const SizedBox(height: 16),
                DemoSection(
                  title: 'Custom Resources',
                  description:
                      'Add custom resource attributes at runtime.',
                  child: CustomResourceDemo(
                    onAttributeAdded: _loadAttributes,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
