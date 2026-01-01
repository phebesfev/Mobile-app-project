import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'folder_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _folderNameController = TextEditingController();

  List<String> _folders = ['General', 'Work', 'Personal', 'Finance'];
  Map<String, int> _folderDocumentCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  Future<void> _loadFolders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot =
          await _firestoreService.getCollection('documents');

      final Map<String, int> counts = {};

      for (String folder in _folders) {
        counts[folder] = 0;
      }

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final folder = data['folder'] as String? ?? 'General';

          counts[folder] = (counts[folder] ?? 0) + 1;

          if (!_folders.contains(folder)) {
            _folders.add(folder);
            counts[folder] = 1;
          }
        }
      }

      setState(() {
        _folderDocumentCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createFolder() async {
    final folderName = _folderNameController.text.trim();

    if (folderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a folder name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_folders.contains(folderName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder already exists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _folders.add(folderName);
      _folderDocumentCounts[folderName] = 0;
    });

    _folderNameController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Folder "$folderName" created'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Folder'),
        content: TextField(
          controller: _folderNameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            hintText: 'Enter folder name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _folderNameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _createFolder,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFolder(String folderName) async {
    if (folderName == 'General') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete the General folder'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Are you sure you want to delete "$folderName"? Documents in this folder will be moved to General.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final querySnapshot =
          await _firestoreService.getCollection('documents');

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['folder'] == folderName) {
          await _firestoreService.setDocument(
            collection: 'documents',
            docId: doc.id,
            data: {
              ...data,
              'folder': 'General',
            },
          );
        }
      }

      setState(() {
        final movedCount = _folderDocumentCounts[folderName] ?? 0;

        _folders.remove(folderName);
        _folderDocumentCounts.remove(folderName);

        _folderDocumentCounts['General'] =
            (_folderDocumentCounts['General'] ?? 0) + movedCount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Folder "$folderName" deleted. Documents moved to General.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting folder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _folders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.folder, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No folders yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    final folderName = _folders[index];
                    final count =
                        _folderDocumentCounts[folderName] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.folder,
                          color:
                              Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        title: Text(
                          folderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '$count document${count != 1 ? 's' : ''}',
                        ),
                        trailing: folderName != 'General'
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteFolder(folderName),
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FolderScreen(
                                folderName: folderName,
                              ),
                            ),
                          ).then((_) => _loadFolders());
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFolderDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
