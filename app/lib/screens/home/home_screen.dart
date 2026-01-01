import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../scan/scan_screen.dart';
import '../files/documents_screen.dart';
import '../files/search_screen.dart';
import '../files/folders_screen.dart';
import '../../services/image_storage_service.dart';
import '../edit_document_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageStorageService _imageStorage = ImageStorageService();
  List<File> _recentDocuments = [];
  bool _isLoadingDocuments = true;

  @override
  void initState() {
    super.initState();
    _loadRecentDocuments();
  }

  Future<void> _loadRecentDocuments() async {
    setState(() {
      _isLoadingDocuments = true;
    });

    try {
      // Get all documents (images + PDFs) - already sorted by date
      final allFiles = await _imageStorage.getAllDocuments();
      
      // Get only the 5 most recent
      setState(() {
        _recentDocuments = allFiles.take(5).toList();
        _isLoadingDocuments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDocuments = false;
      });
    }
  }
  Future<void> _uploadFromPhone() async {
  // Show options: Camera or Gallery
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );

  if (source == null) return;

  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Pick image
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (image != null) {
      // Save to app storage
      await _imageStorage.saveImage(
        File(image.path),
        '', // Auto-generate filename
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Refresh recent documents
        _loadRecentDocuments();
      }
    }
  } catch (e) {
    // Close loading dialog if still open
    if (mounted) Navigator.pop(context);

    // Show error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                const Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                
                // action buttons
                Row(
                  children: [
                    // scan button
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScanScreen(),
                            ),
                          );
                          // Refresh recent documents when returning from scan
                          _loadRecentDocuments();
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.black, size: 28),
                              const SizedBox(height: 4),
                              const Text(
                                'scan',
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // view documents
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DocumentsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description, color: Colors.black, size: 28),
                              const SizedBox(height: 4),
                              const Text(
                                'View Documents',
                                style: TextStyle(color: Colors.black, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // folders button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FoldersScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder, color: Colors.black, size: 28),
                              const SizedBox(height: 4),
                              const Text(
                                'Folders',
                                style: TextStyle(color: Colors.black, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // search bar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: AbsorbPointer(
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.search, color: Colors.black),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // recent documents section
                const Text(
                  'Recent Documents',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                
                // placeholder items
                _buildRecentDocuments(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFromPhone,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRecentDocuments() {
    if (_isLoadingDocuments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentDocuments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.description, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'No documents yet',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _recentDocuments.map((file) {
        final fileName = file.path.split('/').last;
        final fileDate = file.lastModifiedSync();
        final isPdf = fileName.toLowerCase().endsWith('.pdf');
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDocumentPage(filePath: file.path),
                ),
              );
              // Refresh recent documents when returning from edit page
              // This ensures renamed files appear with their new names
              if (result != null || mounted) {
                _loadRecentDocuments();
              }
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isPdf
                        ? Container(
                            width: 40,
                            height: 40,
                            color: Colors.red.shade100,
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 24,
                            ),
                          )
                        : Image.file(
                            file,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${fileDate.day}/${fileDate.month}/${fileDate.year}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Arrow icon
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
