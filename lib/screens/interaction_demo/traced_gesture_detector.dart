import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'interaction_log_store.dart';

class TracedGestureDetector extends StatefulWidget {
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

  @override
  State<TracedGestureDetector> createState() => _TracedGestureDetectorState();
}

class _TracedGestureDetectorState extends State<TracedGestureDetector> {
  Offset? _doubleTapPosition;
  Offset? _dragStartPosition;
  Offset? _dragLastPosition;

  void _recordGesture(String gestureType, {Map<String, String>? extras}) {
    final span = FlutterOTel.tracer.startSpan('ui.gesture.$gestureType');
    span.setStringAttribute('gesture.region', widget.gestureRegion);
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
        action: '$gestureType on ${widget.gestureRegion}',
        timestamp: DateTime.now(),
        spanId: span.spanContext.spanId.toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: widget.onTap != null
          ? (details) {
              _recordGesture('tap', extras: {
                'gesture.x_position':
                    details.localPosition.dx.toStringAsFixed(1),
                'gesture.y_position':
                    details.localPosition.dy.toStringAsFixed(1),
              });
              widget.onTap!();
            }
          : null,
      onLongPressStart: widget.onLongPress != null
          ? (details) {
              _recordGesture('longPress', extras: {
                'gesture.x_position':
                    details.localPosition.dx.toStringAsFixed(1),
                'gesture.y_position':
                    details.localPosition.dy.toStringAsFixed(1),
              });
              widget.onLongPress!();
            }
          : null,
      onDoubleTapDown: widget.onDoubleTap != null
          ? (details) {
              _doubleTapPosition = details.localPosition;
            }
          : null,
      onDoubleTap: widget.onDoubleTap != null
          ? () {
              _recordGesture('doubleTap', extras: {
                'gesture.x_position':
                    _doubleTapPosition?.dx.toStringAsFixed(1) ?? 'unknown',
                'gesture.y_position':
                    _doubleTapPosition?.dy.toStringAsFixed(1) ?? 'unknown',
              });
              _doubleTapPosition = null;
              widget.onDoubleTap!();
            }
          : null,
      onHorizontalDragStart: widget.onHorizontalDragEnd != null
          ? (details) {
              _dragStartPosition = details.localPosition;
              _dragLastPosition = details.localPosition;
            }
          : null,
      onHorizontalDragUpdate: widget.onHorizontalDragEnd != null
          ? (details) {
              _dragLastPosition = details.localPosition;
            }
          : null,
      onHorizontalDragEnd: widget.onHorizontalDragEnd != null
          ? (details) {
              _recordGesture('horizontalDrag', extras: {
                'gesture.start_position':
                    '(${_dragStartPosition?.dx.toStringAsFixed(1)}, ${_dragStartPosition?.dy.toStringAsFixed(1)})',
                'gesture.end_position':
                    '(${_dragLastPosition?.dx.toStringAsFixed(1)}, ${_dragLastPosition?.dy.toStringAsFixed(1)})',
                'gesture.velocity':
                    details.primaryVelocity?.toStringAsFixed(1) ?? 'unknown',
              });
              _dragStartPosition = null;
              _dragLastPosition = null;
              widget.onHorizontalDragEnd!(details);
            }
          : null,
      onVerticalDragStart: widget.onVerticalDragEnd != null
          ? (details) {
              _dragStartPosition = details.localPosition;
              _dragLastPosition = details.localPosition;
            }
          : null,
      onVerticalDragUpdate: widget.onVerticalDragEnd != null
          ? (details) {
              _dragLastPosition = details.localPosition;
            }
          : null,
      onVerticalDragEnd: widget.onVerticalDragEnd != null
          ? (details) {
              _recordGesture('verticalDrag', extras: {
                'gesture.start_position':
                    '(${_dragStartPosition?.dx.toStringAsFixed(1)}, ${_dragStartPosition?.dy.toStringAsFixed(1)})',
                'gesture.end_position':
                    '(${_dragLastPosition?.dx.toStringAsFixed(1)}, ${_dragLastPosition?.dy.toStringAsFixed(1)})',
                'gesture.velocity':
                    details.primaryVelocity?.toStringAsFixed(1) ?? 'unknown',
              });
              _dragStartPosition = null;
              _dragLastPosition = null;
              widget.onVerticalDragEnd!(details);
            }
          : null,
      child: widget.child,
    );
  }
}
