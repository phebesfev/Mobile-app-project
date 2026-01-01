import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;
  ImageStorageService._internal();

  Future<String> saveImage(File imageFile, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(directory.path, 'scanned_images'));
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(imageFile.path);
    final newFileName = fileName.isEmpty 
        ? 'scan_$timestamp$extension'
        : '$fileName$extension';
    
    final savedFile = await imageFile.copy(
      path.join(imagesDir.path, newFileName),
    );

    return savedFile.path;
  }

  Future<List<File>> getAllScannedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(directory.path, 'scanned_images'));
    
    if (!await imagesDir.exists()) {
      return [];
    }

    final files = imagesDir.listSync()
        .whereType<File>()
        .where((file) {
          final ext = path.extension(file.path).toLowerCase();
          return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
        })
        .toList();

    return files;
  }

  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Rename a file to a new name while preserving the extension
  Future<String> renameFile(String oldPath, String newFileName) async {
    final oldFile = File(oldPath);
    if (!await oldFile.exists()) {
      throw Exception('File does not exist: $oldPath');
    }

    final directory = path.dirname(oldPath);
    final extension = path.extension(oldPath);
    
    // Sanitize the new file name (remove invalid characters)
    final sanitizedFileName = newFileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .trim();
    
    final newPath = path.join(directory, '$sanitizedFileName$extension');
    final newFile = await oldFile.rename(newPath);
    
    // Update modification date to current time so it appears in recent documents
    await newFile.setLastModified(DateTime.now());
    
    return newFile.path;
  }

  /// Get all documents (images + PDFs) sorted by modification date
  Future<List<File>> getAllDocuments() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<File> allDocuments = [];

    // Get images from scanned_images folder
    final imagesDir = Directory(path.join(directory.path, 'scanned_images'));
    if (await imagesDir.exists()) {
      final imageFiles = imagesDir.listSync()
          .whereType<File>()
          .where((file) {
            final ext = path.extension(file.path).toLowerCase();
            return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
          })
          .toList();
      allDocuments.addAll(imageFiles);
    }

    // Get PDFs from pdfs folder
    final pdfsDir = Directory(path.join(directory.path, 'pdfs'));
    if (await pdfsDir.exists()) {
      final pdfFiles = pdfsDir.listSync()
          .whereType<File>()
          .where((file) {
            final ext = path.extension(file.path).toLowerCase();
            return ext == '.pdf';
          })
          .toList();
      allDocuments.addAll(pdfFiles);
    }

    // Sort by modification date (newest first)
    allDocuments.sort((a, b) {
      return b.lastModifiedSync().compareTo(a.lastModifiedSync());
    });

    return allDocuments;
  }
}







