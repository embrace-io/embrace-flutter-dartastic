import 'package:flutter/material.dart';

import 'resource_attribute_row.dart';

class SdkResourcesDemo extends StatelessWidget {
  const SdkResourcesDemo({
    super.key,
    required this.attributes,
  });

  final Map<String, String> attributes;

  static const _expectedKeys = [
    'telemetry.sdk.name',
    'telemetry.sdk.version',
    'telemetry.sdk.language',
    'webengine.name',
    'webengine.version',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._expectedKeys.map((key) {
          final value = attributes[key];
          if (value == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      key,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Not available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return ResourceAttributeRow(
            attributeKey: key,
            attributeValue: value,
          );
        }),
        const SizedBox(height: 8),
        Text(
          'See dartastic_opentelemetry on pub.dev for SDK documentation.',
          style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}
