import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../services/storage_service.dart';

class EditImagePage extends StatefulWidget {
  final ImageProvider? image;
  const EditImagePage({super.key, this.image});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  double _brightness = 0.0; // 0 = normal, -1 = dark, 1 = bright
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;
  final StorageService _storageService = StorageService();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _cropImage() async {
    if (_imageFile == null) return;
    final imageCropper = ImageCropper();
    final cropped = await imageCropper.cropImage(
      sourcePath: _imageFile!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );
    if (cropped != null) {
      setState(() {
        _imageFile = File(cropped.path);
      });
    }
  }

  Future<void> _rotateImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image rotation is not supported yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Image'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Image Preview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 220,
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                              _brightnessMatrix(_brightness),
                            ),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        )
                      : widget.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                              _brightnessMatrix(_brightness),
                            ),
                            child: Image(
                              image: widget.image!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image,
                            size: 90,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _cropImage,
                  icon: const Icon(Icons.crop),
                  label: const Text('Crop'),
                ),
                OutlinedButton.icon(
                  onPressed: _rotateImage,
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Rotate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<double> _brightnessMatrix(double brightness) {
    return [
      1,
      0,
      0,
      0,
      255 * brightness,
      0,
      1,
      0,
      0,
      255 * brightness,
      0,
      0,
      1,
      0,
      255 * brightness,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}
