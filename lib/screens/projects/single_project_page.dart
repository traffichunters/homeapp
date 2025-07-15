import 'package:flutter/material.dart';
import '../../models/project.dart';

class SingleProjectPage extends StatelessWidget {
  final Project project;

  const SingleProjectPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (project.description != null && project.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  project.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Created: ${project.createdDate.toString()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Updated: ${project.updatedDate.toString()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}