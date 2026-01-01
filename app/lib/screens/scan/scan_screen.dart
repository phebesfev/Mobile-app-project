import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/image_storage_service.dart';
import '../../services/pdf_service.dart';
// Conditional import for web - stub for mobile, real html for web  
import 'html_stub.dart' if (dart.library.html) 'dart:html' as html;
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageStorageService _imageStorage = ImageStorageService();
  final PdfService _pdfService = PdfService();
  
  File? _capturedImage;
  String? _webImagePath;
  Uint8List? _webImageBytes;
  bool _isProcessing = false;

  Future<void> _takePicture() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (kIsWeb) {
        // For web, use HTML5 camera directly
        await _takePictureWeb();
      } else {
        // For mobile, use image_picker
        await _takePictureMobile();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Camera error: ';
        if (e.toString().contains('permission')) {
          errorMessage = 'Camera permission denied. Please enable camera access in settings.';
        } else if (e.toString().contains('camera')) {
          errorMessage = 'Unable to access camera. Please check if another app is using it.';
        } else {
          errorMessage += e.toString();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _takePictureWeb() async {
    try {
      // Get camera stream
      final stream = await html.window.navigator.mediaDevices?.getUserMedia(
        {'video': {'facingMode': 'user'}}
      );
      
      if (stream != null) {
        // Create video element for camera preview
        final videoElement = html.VideoElement();
        videoElement.srcObject = stream;
        await videoElement.play();
        
        // Wait for video to load
        await Future.delayed(Duration(milliseconds: 1000));
        
        // Create canvas and capture frame
        final canvas = html.CanvasElement();
        final context = canvas.getContext('2d');
        
        if (context != null) {
          canvas.width = videoElement.videoWidth;
          canvas.height = videoElement.videoHeight;
          // Use dynamic cast to avoid type issues
          (context as dynamic).drawImage(videoElement, 0, 0);
          
          // Convert to bytes
          final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
          final base64String = dataUrl.split(',')[1];
          final imageBytes = base64.decode(base64String);
          
          // Stop camera
          stream.getTracks().forEach((track) => track.stop());
          
          setState(() {
            _webImageBytes = imageBytes;
            _webImagePath = dataUrl;
            _capturedImage = null;
          });
        } else {
          throw Exception('Failed to get canvas context');
        }
      } else {
        throw Exception('Failed to access camera');
      }
    } catch (e) {
      throw Exception('Failed to access camera: $e');
    }
  }

  Future<void> _takePictureMobile() async {
    try {
      // Request camera permission and take picture
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90, // Higher quality for documents
        preferredCameraDevice: CameraDevice.rear, // Back camera for documents
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _webImagePath = null;
          _webImageBytes = null;
        });
        
        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveImage() async {
    if (_capturedImage == null && _webImageBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      String savedPath;
      if (kIsWeb && _webImageBytes != null) {
        // For web, we'll handle differently - just show success
        savedPath = 'web_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else if (_capturedImage != null) {
        savedPath = await _imageStorage.saveImage(
          _capturedImage!,
          '',
        );
      } else {
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb 
                ? 'Image captured successfully!' 
                : 'Image saved successfully!'),
          ),
        );
        Navigator.pop(context, savedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _saveAsPdf() async {
    if (_capturedImage == null && _webImageBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      String pdfPath;
      if (kIsWeb && _webImageBytes != null) {
        // For web, PDF creation is different
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF creation not available on web')),
        );
        return;
      } else if (_capturedImage != null) {
        pdfPath = await _pdfService.createPdfFromImage(
          _capturedImage!.path,
          '',
        );
      } else {
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF created successfully!')),
        );
        
        // Ask user if they want to view the PDF
        final shouldView = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('PDF Created'),
            content: const Text('Would you like to view the PDF now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('View'),
              ),
            ],
          ),
        );

        // If user wants to view, open the PDF
        if (shouldView == true) {
          try {
            await _pdfService.viewPdf(pdfPath);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error opening PDF: $e')),
              );
            }
          }
        }
        
        Navigator.pop(context, pdfPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImage = null;
      _webImagePath = null;
      _webImageBytes = null;
    });
  }

  Future<void> _downloadImage() async {
    if (_webImageBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (kIsWeb) {
        // Create a blob and download link for web
        final blob = html.Blob([_webImageBytes!]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image downloaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const Text(
                    'Scan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _capturedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _capturedImage!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : _webImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _webImageBytes!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : CustomPaint(
                              painter: DashedBorderPainter(),
                              child: Container(),
                            ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              if (_capturedImage == null && _webImageBytes == null)
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: IconButton(
                    onPressed: _isProcessing ? null : _takePicture,
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _retakePicture,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _saveImage,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (kIsWeb && _webImageBytes != null) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _downloadImage,
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                      if (!kIsWeb) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _saveAsPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Save as PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const dashWidth = 7.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      path.moveTo(startX, 0);
      path.lineTo(startX + dashWidth, 0);
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    while (startX < size.width) {
      path.moveTo(startX, size.height);
      path.lineTo(startX + dashWidth, size.height);
      startX += dashWidth + dashSpace;
    }

    double startY = 0;
    while (startY < size.height) {
      path.moveTo(0, startY);
      path.lineTo(0, startY + dashWidth);
      startY += dashWidth + dashSpace;
    }

    startY = 0;
    while (startY < size.height) {
      path.moveTo(size.width, startY);
      path.lineTo(size.width, startY + dashWidth);
      startY += dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

