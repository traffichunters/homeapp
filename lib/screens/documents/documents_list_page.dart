import 'package:flutter/material.dart';

class DocumentsListPage extends StatelessWidget {
  const DocumentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Documents Page - Coming Soon'),
      ),
    );
  }
}