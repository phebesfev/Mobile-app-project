import 'package:flutter/material.dart';
import 'dart:io';
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
                  child: widget.image != null
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
