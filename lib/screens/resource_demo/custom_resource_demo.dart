import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';

import 'resource_attribute_row.dart';

class CustomResourceDemo extends StatefulWidget {
  const CustomResourceDemo({
    super.key,
    required this.onAttributeAdded,
  });

  final VoidCallback onAttributeAdded;

  @override
  State<CustomResourceDemo> createState() => _CustomResourceDemoState();
}

class _CustomResourceDemoState extends State<CustomResourceDemo> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  String _selectedType = 'string';
  final List<MapEntry<String, String>> _customAttributes = [];

  static final _keyPattern = RegExp(r'^[a-z][a-z0-9_.]*$');

  static const _typeOptions = ['string', 'int', 'double', 'bool'];

  static const _exampleSuggestions = [
    'team.name',
    'feature.flags',
    'app.version.code',
  ];

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  String? _validateKey(String? value) {
    if (value == null || value.isEmpty) {
      return 'Key is required';
    }
    if (!_keyPattern.hasMatch(value)) {
      return 'Must start with lowercase letter, contain only a-z, 0-9, . or _';
    }
    return null;
  }

  String? _validateValue(String? value) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }
    switch (_selectedType) {
      case 'int':
        if (int.tryParse(value) == null) {
          return 'Must be a valid integer';
        }
      case 'double':
        if (double.tryParse(value) == null) {
          return 'Must be a valid number';
        }
      case 'bool':
        if (value != 'true' && value != 'false') {
          return 'Must be true or false';
        }
    }
    return null;
  }

  void _addAttribute() {
    if (!_formKey.currentState!.validate()) return;

    final key = _keyController.text;
    final value = _valueController.text;

    Attributes newAttributes;
    switch (_selectedType) {
      case 'int':
        newAttributes = OTel.attributesFromList(
            [OTel.attributeInt(key, int.parse(value))]);
      case 'double':
        newAttributes = OTel.attributesFromList(
            [OTel.attributeDouble(key, double.parse(value))]);
      case 'bool':
        newAttributes = OTel.attributesFromList(
            [OTel.attributeBool(key, value == 'true')]);
      default:
        newAttributes = OTel.attributesFromList(
            [OTel.attributeString(key, value)]);
    }

    final newResource = OTel.resource(newAttributes);
    OTel.defaultResource = OTel.defaultResource!.merge(newResource);

    setState(() {
      _customAttributes.add(MapEntry(key, value));
    });

    _keyController.clear();
    _valueController.clear();
    widget.onAttributeAdded();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _keyController,
            decoration: const InputDecoration(
              labelText: 'Attribute Key',
              hintText: 'e.g. team.name',
              border: OutlineInputBorder(),
            ),
            validator: _validateKey,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'Attribute Value',
              border: OutlineInputBorder(),
            ),
            validator: _validateValue,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Value Type',
              border: OutlineInputBorder(),
            ),
            items: _typeOptions.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addAttribute,
              child: const Text('Add Attribute'),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _exampleSuggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  _keyController.text = suggestion;
                },
              );
            }).toList(),
          ),
          if (_customAttributes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Custom Attributes',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ..._customAttributes.map((entry) {
              return ResourceAttributeRow(
                attributeKey: entry.key,
                attributeValue: entry.value,
              );
            }),
          ],
          const SizedBox(height: 8),
          Text(
            'Custom resource attributes appear on all telemetry emitted by this application.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
