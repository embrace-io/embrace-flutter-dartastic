import 'package:flutter/material.dart';

import 'traced_scroll_view.dart';

class ScrollTrackingDemo extends StatelessWidget {
  const ScrollTrackingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scroll the list below to track scroll interactions:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: TracedScrollView(
            containerId: 'demo-list',
            child: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('Item ${index + 1}'),
                  subtitle: Text('Scroll item at index $index'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
