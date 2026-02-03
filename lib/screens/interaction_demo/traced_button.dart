import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'interaction_log_store.dart';

class TracedButton extends StatelessWidget {
  const TracedButton({
    super.key,
    required this.buttonName,
    required this.buttonBuilder,
    this.onPressed,
  });

  final String buttonName;
  final Widget Function(VoidCallback? wrappedOnPressed) buttonBuilder;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return buttonBuilder(
      isEnabled
          ? () {
              final span = FlutterOTel.tracer.startSpan('ui.button.tap');
              span.setStringAttribute('button.name', buttonName);
              span.setBoolAttribute('button.enabled', true);
              span.end();

              InteractionLogStore.instance.recordInteraction(
                InteractionLogEntry(
                  widgetType: 'Button',
                  action: 'tap: $buttonName',
                  timestamp: DateTime.now(),
                  spanId: span.spanContext.spanId.toString(),
                ),
              );

              onPressed!();
            }
          : null,
    );
  }
}
