import 'package:flutter/material.dart';

class ResourceAttributeRow extends StatefulWidget {
  const ResourceAttributeRow({
    super.key,
    required this.attributeKey,
    required this.attributeValue,
    this.source,
  });

  final String attributeKey;
  final String attributeValue;
  final String? source;

  @override
  State<ResourceAttributeRow> createState() => _ResourceAttributeRowState();
}

class _ResourceAttributeRowState extends State<ResourceAttributeRow> {
  bool _expanded = false;

  static const int _truncateLength = 80;

  bool get _needsTruncation =>
      widget.attributeValue.length > _truncateLength;

  String get _displayValue {
    if (_expanded || !_needsTruncation) {
      return widget.attributeValue;
    }
    return '${widget.attributeValue.substring(0, _truncateLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  widget.attributeKey,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      _displayValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (_needsTruncation)
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Text(
                          _expanded ? 'show less' : 'show more',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.source != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                widget.source!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
