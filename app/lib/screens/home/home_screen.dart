import 'package:flutter/material.dart';
import '../files/folders_screen.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Files'),
      ),
      body: StreamBuilder(
        stream: firestoreService.streamCollection(collection: 'folders'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No folders found.'));
          }
          final folders = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(folder['name'] ?? 'Unnamed Folder'),
                  subtitle: FutureBuilder(
                    future: firestoreService.streamCollection(collection: 'documents').first,
                    builder: (context, docSnapshot) {
                      if (!docSnapshot.hasData) return Text('...');
                      final docs = docSnapshot.data!.docs.where((doc) => doc['folder'] == folder['name']).toList();
                      return Text('${docs.length} documents');
                    },
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FolderScreen(
                          folderName: folder['name'] ?? 'Unnamed Folder',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}