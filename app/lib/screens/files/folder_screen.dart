import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/image_storage_service.dart';
import '../edit_document_page.dart';

class FolderScreen extends StatefulWidget {
  final String folderName;

  const FolderScreen({
    super.key,
    required this.folderName,
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ImageStorageService _imageStorage = ImageStorageService();
  List<File> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolderDocuments();
  }

  Future<void> _loadFolderDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all files
      final allFiles = await _imageStorage.getAllDocuments();
      
      // Get documents from Firestore filtered by folder
      final querySnapshot = await _firestoreService.getCollection('documents');
      final Set<String> folderFilePaths = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final folder = data['folder'] as String? ?? 'General';
          if (folder == widget.folderName) {
            final filePath = data['filePath'] as String?;
            if (filePath != null && filePath.isNotEmpty) {
              folderFilePaths.add(filePath);
            }
          }
        }
      }

      // Filter files that belong to this folder
      final folderFiles = allFiles.where((file) {
        return folderFilePaths.contains(file.path);
      }).toList();

      // Sort by modification date (newest first)
      folderFiles.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });

      setState(() {
        _documents = folderFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.folderName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No documents in "${widget.folderName}"',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final file = _documents[index];
                    final fileName = file.path.split('/').last;
                    final isPdf = fileName.toLowerCase().endsWith('.pdf');
                    
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDocumentPage(filePath: file.path),
                          ),
                        );
                        // Refresh when returning from edit page
                        if (result != null || mounted) {
                          _loadFolderDocuments();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: isPdf
                              ? Container(
                                  color: Colors.red.shade50,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          fileName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image, size: 48),
                                    );
                                  },
                                ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

