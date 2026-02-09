import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'interaction_log_store.dart';

class _FieldFocusData {
  final String fieldName;
  DateTime? focusStart;
  Duration totalFocusDuration = Duration.zero;
  int focusCount = 0;
  int charsTyped = 0;
  int _lastTextLength = 0;

  _FieldFocusData(this.fieldName);

  void onTextChanged(String text) {
    final newLength = text.length;
    if (newLength > _lastTextLength) {
      charsTyped += newLength - _lastTextLength;
    }
    _lastTextLength = newLength;
  }
}

class FormInteractionDemo extends StatefulWidget {
  const FormInteractionDemo({super.key});

  @override
  State<FormInteractionDemo> createState() => _FormInteractionDemoState();
}

class _FormInteractionDemoState extends State<FormInteractionDemo> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _ageFocus = FocusNode();

  late final Map<String, _FieldFocusData> _fieldData;

  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _fieldData = {
      'name': _FieldFocusData('name'),
      'email': _FieldFocusData('email'),
      'age': _FieldFocusData('age'),
    };

    _nameFocus.addListener(() => _onFocusChanged('name', _nameFocus.hasFocus));
    _emailFocus
        .addListener(() => _onFocusChanged('email', _emailFocus.hasFocus));
    _ageFocus.addListener(() => _onFocusChanged('age', _ageFocus.hasFocus));

    _nameController.addListener(
      () => _fieldData['name']!.onTextChanged(_nameController.text),
    );
    _emailController.addListener(
      () => _fieldData['email']!.onTextChanged(_emailController.text),
    );
    _ageController.addListener(
      () => _fieldData['age']!.onTextChanged(_ageController.text),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  void _onFocusChanged(String fieldName, bool hasFocus) {
    final data = _fieldData[fieldName]!;

    if (hasFocus) {
      data.focusStart = DateTime.now();
      data.focusCount++;

      final span = FlutterOTel.tracer.startSpan('ui.form_field.focus');
      span.setStringAttribute('field.name', fieldName);
      span.setIntAttribute('field.focus_count', data.focusCount);
      span.end();
    } else if (data.focusStart != null) {
      data.totalFocusDuration +=
          DateTime.now().difference(data.focusStart!);
      data.focusStart = null;
    }
  }

  void _onSubmit() {
    final isValid = _formKey.currentState!.validate();

    final parentSpan = FlutterOTel.tracer.startSpan('ui.form.submit');
    parentSpan.setBoolAttribute('form.valid', isValid);
    parentSpan.setIntAttribute('form.field_count', _fieldData.length);

    for (final entry in _fieldData.entries) {
      final data = entry.value;
      // End any ongoing focus.
      if (data.focusStart != null) {
        data.totalFocusDuration +=
            DateTime.now().difference(data.focusStart!);
        data.focusStart = null;
      }

      final childSpan = FlutterOTel.tracer.startSpan(
        'ui.form_field.interaction',
        parentSpan: parentSpan,
      );
      childSpan.setStringAttribute('field.name', data.fieldName);
      childSpan.setIntAttribute('field.focus_count', data.focusCount);
      childSpan.setIntAttribute(
        'field.total_focus_ms',
        data.totalFocusDuration.inMilliseconds,
      );
      childSpan.setIntAttribute('field.chars_typed', data.charsTyped);
      childSpan.end();
    }

    if (!isValid) {
      parentSpan.addEventNow('validation_error');
    }

    parentSpan.end();

    InteractionLogStore.instance.recordInteraction(
      InteractionLogEntry(
        widgetType: 'Form',
        action: isValid ? 'submit (valid)' : 'submit (invalid)',
        timestamp: DateTime.now(),
        spanId: parentSpan.spanContext.spanId.toString(),
      ),
    );

    setState(() {
      _statusText = isValid ? 'Form submitted!' : 'Validation failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ageController,
            focusNode: _ageFocus,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Age is required';
              }
              final age = int.tryParse(value);
              if (age == null || age < 0 || age > 150) {
                return 'Enter a valid age';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSubmit,
              child: const Text('Submit'),
            ),
          ),
          if (_statusText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _statusText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _statusText.contains('failed')
                        ? Colors.red
                        : Colors.green,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
