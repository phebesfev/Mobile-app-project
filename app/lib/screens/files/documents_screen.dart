import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/image_storage_service.dart';
import '../edit_document_page.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ImageStorageService _imageStorage = ImageStorageService();
  List<File> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all documents (images + PDFs) - already sorted by date
      final files = await _imageStorage.getAllDocuments();
      
      setState(() {
        _documents = files;
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
        title: const Text('Documents'),
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
                        'No documents yet',
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
                        // Refresh documents when returning from edit page
                        if (result != null || mounted) {
                          _loadDocuments();
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
                                ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}