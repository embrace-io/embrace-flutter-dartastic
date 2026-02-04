import 'package:flutter/material.dart';

import 'sampler_type.dart';

class SamplerSelector extends StatelessWidget {
  const SamplerSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final SamplerType selectedType;
  final ValueChanged<SamplerType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedType.displayName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          selectedType.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        DropdownButton<SamplerType>(
          value: selectedType,
          isExpanded: true,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          items: SamplerType.values
              .map(
                (type) => DropdownMenuItem<SamplerType>(
                  value: type,
                  child: Text(type.displayName),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
