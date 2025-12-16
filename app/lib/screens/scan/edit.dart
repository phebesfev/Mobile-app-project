import 'package:flutter/material.dart';

class EditDocumentPage extends StatefulWidget {
  const EditDocumentPage({super.key});

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Document'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit your document details below:',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Add your editing widgets here
            Container(
              height: 180,
              color: Colors.grey[300],
              child: Center(
                child: Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),