import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(labelText: 'Tags'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedFolder,
              items: const [
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(value: 'Work', child: Text('Work')),
                DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                DropdownMenuItem(value: 'Finance', child: Text('Finance')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFolder = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Folder'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description / Notes',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
