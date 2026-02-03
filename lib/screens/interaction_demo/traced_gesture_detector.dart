import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'interaction_log_store.dart';

class TracedGestureDetector extends StatelessWidget {
  const TracedGestureDetector({
    super.key,
    required this.child,
    required this.gestureRegion,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onHorizontalDragEnd,
    this.onVerticalDragEnd,
  });

  final Widget child;
  final String gestureRegion;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final ValueChanged<DragEndDetails>? onHorizontalDragEnd;
  final ValueChanged<DragEndDetails>? onVerticalDragEnd;

  void _recordGesture(String gestureType, {Map<String, String>? extras}) {
    final span = FlutterOTel.tracer.startSpan('ui.gesture.$gestureType');
    span.setStringAttribute('gesture.region', gestureRegion);
    span.setStringAttribute('gesture.type', gestureType);
    if (extras != null) {
      for (final entry in extras.entries) {
        span.setStringAttribute(entry.key, entry.value);
      }
    }
    span.end();

    InteractionLogStore.instance.recordInteraction(
      InteractionLogEntry(
        widgetType: 'Gesture',
        action: '$gestureType on $gestureRegion',
        timestamp: DateTime.now(),
        spanId: span.spanContext.spanId.toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              _recordGesture('tap');
              onTap!();
            }
          : null,
      onLongPress: onLongPress != null
          ? () {
              _recordGesture('longPress');
              onLongPress!();
            }
          : null,
      onDoubleTap: onDoubleTap != null
          ? () {
              _recordGesture('doubleTap');
              onDoubleTap!();
            }
          : null,
      onHorizontalDragEnd: onHorizontalDragEnd != null
          ? (details) {
              _recordGesture('horizontalDrag', extras: {
                'gesture.velocity':
                    details.primaryVelocity?.toStringAsFixed(1) ?? 'unknown',
              });
              onHorizontalDragEnd!(details);
            }
          : null,
      onVerticalDragEnd: onVerticalDragEnd != null
          ? (details) {
              _recordGesture('verticalDrag', extras: {
                'gesture.velocity':
                    details.primaryVelocity?.toStringAsFixed(1) ?? 'unknown',
              });
              onVerticalDragEnd!(details);
            }
          : null,
      child: child,
    );
  }
}
