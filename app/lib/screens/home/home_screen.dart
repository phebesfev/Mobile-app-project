import 'package:flutter/material.dart';
import '../files/folders_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example folders and documents for UI demonstration
    final folders = [
      {'name': 'Receipts', 'documents': ['Receipt Jan.pdf', 'Receipt Feb.pdf']},
      {'name': 'School', 'documents': ['Math Notes.pdf', 'Science Project.pdf']},
      {'name': 'Personal', 'documents': []},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Files'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: Text(folder['name'] as String),
              subtitle: Text(
                '${(folder['documents'] as List).length} documents',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderScreen(
                      folderName: folder['name'] as String,
                      documents: List<String>.from(folder['documents'] as List),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
