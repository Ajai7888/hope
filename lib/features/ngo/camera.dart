import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;
  bool _isRecognizing = false;
  String? _recognitionResult;
  int _imageCount = 0; // A counter to simulate different recognition results

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      if (!mounted) return;
      setState(() {
        _selectedImage = File(pickedImage.path);
        _recognitionResult = null;
        _imageCount++; // Increment the counter for each new image
      });
      _recognizeImage();
    }
  }

  void _recognizeImage() {
    if (_selectedImage == null) return;

    if (!mounted) return;
    setState(() {
      _isRecognizing = true;
      _recognitionResult = 'Recognizing...';
    });

    // Simulating API call with a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isRecognizing = false;
        if (_imageCount % 3 == 1) {
          // First image (and every third image after that) is a full match
          _recognitionResult =
              'Match found:\nName: Abhinav\nNGO: Nalam NGO\nArea: Karapakkam';
        } else if (_imageCount % 3 == 2) {
          // Second image (and every third image after that) is a different full match
          _recognitionResult =
              'Match found:\nName: Brayon\nNGO: Smile Foundation\nArea: Sholinganallur';
        } else {
          // Third image (and every third image after that) is not a match
          _recognitionResult = 'No match found.';
        }
      });
    });
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Image Recognition',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B2A41),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B2A41), Color(0xFF475B76)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image display area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: 100,
                            color: Colors.white54,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Button to pick image
              ElevatedButton.icon(
                onPressed: _isRecognizing ? null : _showImageSourceDialog,
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text(
                  'Select Image',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E639A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Recognition Result Display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isRecognizing
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _recognitionResult != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _recognitionResult!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          'Select an image to start recognition.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
