import 'package:flutter/material.dart';

import 'resource_attribute_row.dart';

class PlatformResourcesDemo extends StatelessWidget {
  const PlatformResourcesDemo({
    super.key,
    required this.attributes,
  });

  final Map<String, String> attributes;

  static const _expectedKeys = [
    'os.type',
    'os.version',
    'os.description',
    'host.arch',
    'host.name',
    'device.model.name',
    'device.manufacturer',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _expectedKeys.map((key) {
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
                    'Not available on this platform',
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
      }).toList(),
    );
  }
}
