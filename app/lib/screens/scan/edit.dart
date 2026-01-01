import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_image_page.dart';
import '../../services/firestore_service.dart';

class EditDocumentPage extends StatefulWidget {
  const EditDocumentPage({super.key});

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedFolder;
  bool _isLoading = false;
  String? _errorMessage;
  String? _imageUrl;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveDocument() async {
    // Validate title
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a title';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final docId = _titleController.text
          .trim()
          .replaceAll(' ', '_')
          .toLowerCase();
      
      await _firestoreService.setDocument(
        collection: 'documents',
        docId: docId,
        data: {
          'title': _titleController.text.trim(),
          'tags': _tagsController.text.trim(),
          'folder': _selectedFolder ?? 'General',
          'description': _descriptionController.text.trim(),
          'imageUrl': _imageUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Optionally navigate back after saving
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.edit_document,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text('Edit Document'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
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
                    child: Center(
                      child: Icon(
                        Icons.insert_drive_file,
                        size: 100,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditImagePage(),
                          ),
                        );
                        if (url != null && mounted) {
                          setState(() {
                            _imageUrl = url;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                        size: 26,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Edit Image',
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
            ),
            const SizedBox(height: 28),
            // Document details card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
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
                      Text(
                        'Document Details',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
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
                  ),
                  const SizedBox(height: 14),
                  Row(
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
                          items: [
                            DropdownMenuItem(
                              value: 'General',
                              child: Text('General'),
                            ),
                            DropdownMenuItem(
                              value: 'Work',
                              child: Text('Work'),
                            ),
                            DropdownMenuItem(
                              value: 'Personal',
                              child: Text('Personal'),
                            ),
                            DropdownMenuItem(
                              value: 'Finance',
                              child: Text('Finance'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFolder = value;
                            });
                          },
                        ),
                      ),
                    ],
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
                    onPressed: _isLoading ? null : _saveDocument,
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                          : Text(
                              'Save Changes',
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
                const SizedBox(width: 14),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.primary,
                      size: 26,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
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
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
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
