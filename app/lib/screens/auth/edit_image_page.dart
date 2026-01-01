import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage({super.key});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageUrl = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Image'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageUrl != null)
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(_imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image, size: 100, color: Colors.grey[400]),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_library),
              label: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            if (_imageUrl != null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, _imageUrl);
                },
                icon: Icon(Icons.check),
                label: Text('Use This Image'),
              ),
          ],
        ),
      ),
    );
  }
}
