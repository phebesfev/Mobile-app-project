import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';

/// Handles PDF creation and viewing
/// 
/// This service converts images to PDFs and opens them for viewing
class PdfService {
  /// Converts an image file to PDF and saves it
  /// 
  /// Takes the path to an image file, creates a PDF from it,
  /// saves it to the app's storage, and returns the path to the PDF
  Future<String> createPdfFromImage(String imagePath, String fileName) async {
    // First, make sure the image file actually exists
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw Exception('Image file not found');
    }

    // Read the image file into memory
    final imageBytes = await imageFile.readAsBytes();

    // Create a new PDF document
    final pdf = pw.Document();
    
    // Convert the image bytes into a format the PDF library can use
    final pdfImage = pw.MemoryImage(imageBytes);

    // Add a page to the PDF and put the image on it
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // Standard paper size
        build: (pw.Context context) {
          // Center the image on the page
          return pw.Center(
            child: pw.Image(
              pdfImage,
              fit: pw.BoxFit.contain, // Keep image proportions
            ),
          );
        },
      ),
    );

    // Get where we should save files (app's documents folder)
    final directory = await getApplicationDocumentsDirectory();
    final pdfsFolder = Directory(path.join(directory.path, 'pdfs'));
    
    // Create the pdfs folder if it doesn't exist yet
    if (!await pdfsFolder.exists()) {
      await pdfsFolder.create(recursive: true);
    }

    // Create a filename for the PDF
    // If fileName is provided, use it. Otherwise use a timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final pdfName = fileName.isEmpty 
        ? 'document_$timestamp.pdf'
        : '$fileName.pdf';
    
    // Full path where we'll save the PDF
    final pdfPath = path.join(pdfsFolder.path, pdfName);
    
    // Save the PDF to the file system
    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

    // Return the path so the caller knows where the PDF was saved
    return pdfPath;
  }

  /// Opens a PDF file using the device's default PDF viewer
  /// 
  /// This will open the PDF in whatever app the user has set up
  /// to view PDFs (like Adobe Reader, Chrome, etc.)
  Future<void> viewPdf(String pdfPath) async {
    // Make sure the file exists before trying to open it
    final file = File(pdfPath);
    if (!await file.exists()) {
      throw Exception('PDF file not found');
    }

    // Open the file with the system's default PDF viewer
    await OpenFile.open(pdfPath);
  }
}
