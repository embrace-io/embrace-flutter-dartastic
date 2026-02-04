import 'package:flutter/material.dart';

import 'resource_attribute_row.dart';

class ServiceResourcesDemo extends StatelessWidget {
  const ServiceResourcesDemo({
    super.key,
    required this.attributes,
  });

  final Map<String, String> attributes;

  static const _expectedKeys = [
    'service.name',
    'service.version',
    'service.namespace',
    'service.instance.id',
    'deployment.environment',
  ];

  static const _autoDetectedKeys = {'service.instance.id'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._expectedKeys.map((key) {
          final value = attributes[key];
          if (value == null) {
            return ResourceAttributeRow(
              attributeKey: key,
              attributeValue: 'Not configured',
              source: null,
            );
          }
          return ResourceAttributeRow(
            attributeKey: key,
            attributeValue: value,
            source: _autoDetectedKeys.contains(key)
                ? 'auto-detected'
                : 'configured',
          );
        }),
        const SizedBox(height: 8),
        Text(
          'These attributes are set in FlutterOTel.initialize().',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}
