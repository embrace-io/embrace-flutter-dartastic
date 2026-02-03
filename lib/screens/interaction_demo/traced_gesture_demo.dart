import 'package:flutter/material.dart';

import 'traced_gesture_detector.dart';

class TracedGestureDemo extends StatefulWidget {
  const TracedGestureDemo({super.key});

  @override
  State<TracedGestureDemo> createState() => _TracedGestureDemoState();
}

class _TracedGestureDemoState extends State<TracedGestureDemo> {
  String _lastGesture = 'None';
  Color _boxColor = Colors.blue.shade100;

  void _flashColor(Color color) {
    setState(() => _boxColor = color);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _boxColor = Colors.blue.shade100);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last gesture: $_lastGesture',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TracedGestureDetector(
          gestureRegion: 'gesture-box',
          onTap: () {
            setState(() => _lastGesture = 'tap');
            _flashColor(Colors.green.shade100);
          },
          onLongPress: () {
            setState(() => _lastGesture = 'longPress');
            _flashColor(Colors.orange.shade100);
          },
          onDoubleTap: () {
            setState(() => _lastGesture = 'doubleTap');
            _flashColor(Colors.purple.shade100);
          },
          onHorizontalDragEnd: (_) {
            setState(() => _lastGesture = 'horizontalDrag');
            _flashColor(Colors.red.shade100);
          },
          onVerticalDragEnd: (_) {
            setState(() => _lastGesture = 'verticalDrag');
            _flashColor(Colors.teal.shade100);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _boxColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              'Gesture Area\nTap, long-press, double-tap, or drag',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
