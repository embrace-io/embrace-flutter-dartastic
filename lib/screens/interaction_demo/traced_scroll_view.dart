import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

import 'interaction_log_store.dart';

class TracedScrollView extends StatefulWidget {
  const TracedScrollView({
    super.key,
    required this.containerId,
    required this.child,
    this.scrollDirection = Axis.vertical,
  });

  final String containerId;
  final Widget child;
  final Axis scrollDirection;

  @override
  State<TracedScrollView> createState() => _TracedScrollViewState();
}

class _TracedScrollViewState extends State<TracedScrollView> {
  Span? _activeSpan;
  Timer? _debounceTimer;
  double _scrollStartOffset = 0;
  double _peakVelocity = 0;

  void _onScrollStart(ScrollStartNotification notification) {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    _scrollStartOffset = notification.metrics.pixels;
    _peakVelocity = 0;

    _activeSpan = FlutterOTel.tracer.startSpan('ui.scroll.start');
    _activeSpan!.setStringAttribute('scroll.container_id', widget.containerId);
  }

  void _onScrollUpdate(ScrollUpdateNotification notification) {
    _lastScrollOffset = notification.metrics.pixels;
    final velocity = notification.dragDetails?.delta.distance ?? 0;
    if (velocity > _peakVelocity) {
      _peakVelocity = velocity;
    }
  }

  void _onScrollEnd() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _endScrollSpan();
    });
  }

  double _lastScrollOffset = 0;

  void _endScrollSpan() {
    if (_activeSpan == null) return;

    final delta = _lastScrollOffset - _scrollStartOffset;
    final distance = delta.abs();

    String direction;
    if (widget.scrollDirection == Axis.vertical) {
      direction = delta > 0 ? 'down' : 'up';
    } else {
      direction = delta > 0 ? 'right' : 'left';
    }

    _activeSpan!.setStringAttribute('scroll.direction', direction);
    _activeSpan!.setDoubleAttribute('scroll.distance_pixels', distance);
    _activeSpan!.setDoubleAttribute(
      'scroll.peak_velocity',
      _peakVelocity,
    );
    _activeSpan!.end();

    InteractionLogStore.instance.recordInteraction(
      InteractionLogEntry(
        widgetType: 'Scroll',
        action: 'scroll on ${widget.containerId}',
        timestamp: DateTime.now(),
        spanId: _activeSpan!.spanContext.spanId.toString(),
      ),
    );

    _activeSpan = null;
    _peakVelocity = 0;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_activeSpan != null) {
      _activeSpan!.end();
      _activeSpan = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _onScrollStart(notification);
        } else if (notification is ScrollUpdateNotification) {
          _onScrollUpdate(notification);
        } else if (notification is ScrollEndNotification) {
          _onScrollEnd();
        }
        return true;
      },
      child: widget.child,
    );
  }
}
