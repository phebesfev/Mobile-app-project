import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveDocument() async {
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
          'folder': _selectedFolder ?? '',
          'description': _descriptionController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document saved!')));
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final docId = _titleController.text
          .trim()
          .replaceAll(' ', '_')
          .toLowerCase();

      await _firestoreService.deleteDocument(
        collection: 'documents',
        docId: docId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document deleted!')));
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Document')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _saveDocument,
            child: const Text('Save'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _deleteDocument,
            child: const Text('Delete'),
          ),
          if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
