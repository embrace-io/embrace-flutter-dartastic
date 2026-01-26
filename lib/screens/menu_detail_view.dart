import 'package:flutter/material.dart';

class MenuDetailView extends StatelessWidget {
  const MenuDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Menu 0'),
      ),
      body: const Center(
        child: Text('The View'),
      ),
    );
  }
}
