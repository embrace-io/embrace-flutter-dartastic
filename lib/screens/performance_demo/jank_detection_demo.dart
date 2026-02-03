import 'dart:async';

import 'package:flutter/material.dart';

import 'jank_detector.dart';

class JankDetectionDemo extends StatefulWidget {
  const JankDetectionDemo({super.key});

  @override
  State<JankDetectionDemo> createState() => _JankDetectionDemoState();
}

class _JankDetectionDemoState extends State<JankDetectionDemo> {
  final _detector = JankDetector.instance;
  bool _flashActive = false;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _detector.addListener(_onChanged);
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _detector.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final hadJank =
        _detector.jankFrames > 0 || _detector.severeFrames > 0;
    setState(() {
      if (hadJank && !_flashActive) {
        _flashActive = true;
        _flashTimer?.cancel();
        _flashTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _flashActive = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _flashActive
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricRow(
                label: 'Jank Frames',
                value: '${_detector.jankFrames}',
              ),
              const SizedBox(height: 4),
              _MetricRow(
                label: 'Severe Jank',
                value: '${_detector.severeFrames}',
              ),
              const SizedBox(height: 4),
              _MetricRow(
                label: 'Jank %',
                value: '${_detector.jankPercentage.toStringAsFixed(1)}%',
              ),
              if (_detector.lastJankTimestamp != null) ...[
                const SizedBox(height: 4),
                _MetricRow(
                  label: 'Last Jank',
                  value: _formatTimestamp(_detector.lastJankTimestamp!),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime ts) {
    return '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}:'
        '${ts.second.toString().padLeft(2, '0')}';
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
