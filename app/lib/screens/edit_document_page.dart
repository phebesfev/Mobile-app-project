import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import '../services/firestore_service.dart';
import '../services/image_storage_service.dart';

class EditDocumentPage extends StatefulWidget {
  final String? filePath;
  
  const EditDocumentPage({super.key, this.filePath});

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedFolder = 'General';
  List<String> _folders = ['General', 'Work', 'Personal', 'Finance'];
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isLoadingData = true;
  String? _errorMessage;
  String? _imageUrl;
  final FirestoreService _firestoreService = FirestoreService();
  final ImageStorageService _imageStorage = ImageStorageService();

  @override
  void initState() {
    super.initState();
    // get the filename and use it as default title
    if (widget.filePath != null) {
      final fileName = path.basename(widget.filePath!);
      final fileNameWithoutExt = fileName.replaceAll(path.extension(fileName), '');
      _titleController.text = fileNameWithoutExt;
    }
    // load data from firestore
    _loadDocumentData();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      // get folders from firestore
      final querySnapshot = await _firestoreService.getCollection('documents');
      final Set<String> folders = {'General', 'Work', 'Personal', 'Finance'};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final folder = data['folder'] as String?;
          if (folder != null && folder.isNotEmpty) {
            folders.add(folder);
          }
        }
      }

      if (mounted) {
        final folderList = folders.toList();
        folderList.sort();
        setState(() {
          _folders = folderList;
        });
      }
    } catch (e) {
      debugPrint('Error loading folders: $e');
      // just use default folders if something goes wrong
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildFilePreview(String filePath) {
    final fileName = path.basename(filePath);
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    
    if (isPdf) {
      return Container(
        color: Colors.red.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                fileName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    } else {
      return Image.file(
        File(filePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image,
              size: 80,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }

  Future<void> _loadDocumentData() async {
    // stop showing loading spinner
    setState(() {
      _isLoadingData = false;
    });

    if (widget.filePath == null) {
      return;
    }

    // get saved data from firestore
    try {
      final fileName = path.basename(widget.filePath!);
      final docId = fileName
          .replaceAll(path.extension(fileName), '')
          .replaceAll(' ', '_')
          .toLowerCase();

      final docSnapshot = await _firestoreService.getDocument(
        collection: 'documents',
        docId: docId,
      );

      if (docSnapshot.exists && mounted) {
        final docData = docSnapshot.data() as Map<String, dynamic>?;
        if (docData != null) {
          setState(() {
            // only update title if it's still the default filename
            final currentTitle = _titleController.text;
            final defaultTitle = fileName.replaceAll(path.extension(fileName), '');
            if (currentTitle.isEmpty || currentTitle == defaultTitle) {
              _titleController.text = docData['title'] ?? _titleController.text;
            }
            _tagsController.text = docData['tags'] ?? '';
            _selectedFolder = docData['folder'] ?? 'General';
            _descriptionController.text = docData['description'] ?? '';
            _imageUrl = docData['imageUrl'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading document data: $e');
      // ignore errors, just use defaults
    }
  }

  Future<void> _saveDocument() async {
    // check if title is empty
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? newFilePath = widget.filePath;
    bool wasRenamed = false;

    try {
      final docId = _titleController.text
          .trim()
          .replaceAll(' ', '_')
          .toLowerCase();
      
      // rename file if needed
      if (widget.filePath != null) {
        final newTitle = _titleController.text.trim();
        try {
          final oldFileName = path.basename(widget.filePath!);
          newFilePath = await _imageStorage.renameFile(
            widget.filePath!,
            newTitle,
          );
          wasRenamed = oldFileName != path.basename(newFilePath);
        } catch (renameError) {
          debugPrint('Error renaming file: $renameError');
          // keep using old path if rename fails
        }
      }
      
      // prepare data for firestore
      final firestoreData = {
        'title': _titleController.text.trim(),
        'tags': _tagsController.text.trim(),
        'folder': _selectedFolder ?? 'General',
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrl ?? '',
        'filePath': newFilePath ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // stop loading spinner
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });

      // show success message
      if (wasRenamed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'File renamed to: ${path.basename(newFilePath!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // go back to previous screen
      Navigator.pop(context, newFilePath);

      // save to firestore in the background
      _firestoreService.setDocument(
        collection: 'documents',
        docId: docId,
        data: firestoreData,
      ).catchError((error) {
        debugPrint('Background Firestore save error: $error');
      });
    } catch (e) {
      if (!mounted) return;

      // figure out what kind of error it is
      String errorMsg = 'Failed to save document. ';
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('permission_denied') || 
          errorString.contains('firestore api has not been used')) {
        errorMsg = 'Firestore API is not enabled. Please enable it in Google Cloud Console:\n';
        errorMsg += 'https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=quick-scanner-27853';
      } else if (errorString.contains('network')) {
        errorMsg += 'Network error. Please check your internet connection.';
      } else if (errorString.contains('timeout')) {
        errorMsg += 'Request timed out. Please try again.';
      } else {
        errorMsg += e.toString();
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });

      String snackBarMsg;
      if (errorString.contains('permission_denied') || 
          errorString.contains('firestore api has not been used')) {
        snackBarMsg = 'Firestore API not enabled. Check error details below.';
      } else {
        snackBarMsg = 'Error saving document. Please try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackBarMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deleteDocument() async {
    // ask user to confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to permanently delete this document? This action cannot be undone.'),
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

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final docId = _titleController.text
          .trim()
          .replaceAll(' ', '_')
          .toLowerCase();
      
      // delete the file from device
      if (widget.filePath != null) {
        try {
          await _imageStorage.deleteImage(widget.filePath!);
        } catch (fileError) {
          debugPrint('Error deleting local file: $fileError');
          // still try to delete from firestore even if file delete fails
        }
      }

      // stop loading spinner
      setState(() {
        _isDeleting = false;
        _errorMessage = null;
      });

      // show success message
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Deleted Successfully',
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Text(
            'Document has been permanently deleted.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // go back to previous screen
      if (mounted) {
        Navigator.pop(context);
      }

      // delete from firestore in background
      _firestoreService.deleteDocument(
        collection: 'documents',
        docId: docId,
      ).catchError((error) {
        debugPrint('Background Firestore delete error: $error');
      });
    } catch (e) {
      if (!mounted) return;

      String errorMsg = 'Failed to delete document. ';
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('permission_denied') || 
          errorString.contains('firestore api has not been used')) {
        errorMsg = 'Firestore API is not enabled. Please enable it in Google Cloud Console.';
      } else if (errorString.contains('network')) {
        errorMsg += 'Network error. Please check your internet connection.';
      } else {
        errorMsg += e.toString();
      }

      setState(() {
        _isDeleting = false;
        _errorMessage = errorMsg;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error deleting document. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_document,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Edit Document',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 220,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.13),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _isLoadingData
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : widget.filePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: _buildFilePreview(widget.filePath!),
                              )
                            : _imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(
                                      _imageUrl!,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.insert_drive_file,
                                      size: 100,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.22),
                                    ),
                                  ),
                  ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Document Details',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. Passport, Invoice, Certificate',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // stack tags and folder vertically on small screens, side by side on bigger screens
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            TextFormField(
                              controller: _tagsController,
                              decoration: InputDecoration(
                                labelText: 'Tags',
                                hintText: 'e.g. work, personal, tax',
                                prefixIcon: Icon(Icons.label),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: _selectedFolder,
                              decoration: InputDecoration(
                                labelText: 'Folder',
                                prefixIcon: Icon(Icons.folder),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              items: _folders.map((folder) {
                                return DropdownMenuItem(
                                  value: folder,
                                  child: Text(
                                    folder,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedFolder = value;
                                });
                              },
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _tagsController,
                                decoration: InputDecoration(
                                  labelText: 'Tags',
                                  hintText: 'e.g. work, personal, tax',
                                  prefixIcon: Icon(Icons.label),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                ),
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedFolder,
                                decoration: InputDecoration(
                                  labelText: 'Folder',
                                  prefixIcon: Icon(Icons.folder),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                ),
                                items: _folders.map((folder) {
                                  return DropdownMenuItem(
                                    value: folder,
                                    child: Text(
                                      folder,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFolder = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description / Notes',
                      hintText: 'Add details or notes about this document',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_isLoading || _isDeleting) ? null : _saveDocument,
                    icon: Icon(
                      Icons.save,
                      color: Theme.of(context).colorScheme.primary,
                      size: 26,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Save Changes',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    letterSpacing: 0.2,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shadowColor: Colors.black.withOpacity(0.08),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_isLoading || _isDeleting) ? null : _deleteDocument,
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.primary,
                      size: 26,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _isDeleting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                          : Text(
                              'Delete',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    letterSpacing: 0.2,
                                  ),
                            ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shadowColor: Colors.black.withOpacity(0.08),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
