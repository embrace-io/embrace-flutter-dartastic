import 'package:flutter/material.dart';

class ErrorsPage extends StatelessWidget {
  const ErrorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Errors'),
      ),
      body: const Center(
        child: Text('Error testing will go here'),
      ),
    );
  }
}
