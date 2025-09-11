import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: const Color(0xFF1B2A41),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('This is the Camera Screen')),
    );
  }
}
