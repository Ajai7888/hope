import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  final _incidentDescriptionController = TextEditingController();
  final _locationController =
      TextEditingController(); // ✅ Controller for location
  final MapController _mapController = MapController();
  LatLng _currentLatLng = LatLng(20.5937, 78.9629); // fallback: India
  String _currentAddress = 'Getting location...';
  StreamSubscription<Position>? _positionStream;
  File? _capturedImage;

  /// ✅ Replace this with your **own valid Mapbox token**
  final String mapboxAccessToken =
      "pk.eyJ1Ijoic2F0aXNoZW1hIiwiYSI6ImNtYnEzMnltOTA0ODYyanF6dDNubHQ0ZDAifQ.WiSaOShEAjHlUtvN68VjjA";

  @override
  void initState() {
    super.initState();
    _locationController.text = _currentAddress; // set initial
    _setupLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _incidentDescriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Request service + permission, then start live updates
  Future<void> _setupLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    _getLiveLocation();
  }

  /// Get initial location + listen for changes
  void _getLiveLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _updateLocation(pos);

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      ).listen((pos) => _updateLocation(pos));
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  /// Update map + address field
  Future<void> _updateLocation(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (!mounted) return;
      setState(() {
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
        _currentAddress =
            "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
        _locationController.text = _currentAddress; // ✅ keep text box updated
      });

      _mapController.move(_currentLatLng, 16.0);
    } catch (e) {
      debugPrint("Reverse geocoding failed: $e");
    }
  }

  /// Capture image with camera
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedImage != null) {
      setState(() => _capturedImage = File(pickedImage.path));
    }
  }

  /// Submit report to Firebase (Storage + Firestore) + notify NGO admins
  Future<void> _submitReport() async {
    if (_incidentDescriptionController.text.isEmpty || _capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture an image and add details'),
        ),
      );
      return;
    }

    try {
      // 1️⃣ Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('reports')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_capturedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      // 2️⃣ Save report in Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'description': _incidentDescriptionController.text,
        'address': _currentAddress,
        'latitude': _currentLatLng.latitude,
        'longitude': _currentLatLng.longitude,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Report submitted successfully!')),
      );

      // Clear form after submit
      setState(() {
        _capturedImage = null;
        _incidentDescriptionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to submit report: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Citizen Incident Reporting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // If an image is captured, swap back to map
            if (_capturedImage != null) {
              setState(() => _capturedImage = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Map or image
            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _capturedImage == null
                    ? FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentLatLng,
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken",
                            userAgentPackageName: "com.example.hope",
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLatLng,
                                width: 60,
                                height: 60,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Image.file(_capturedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            /// Capture photo
            ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Incident Photo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Location auto-fill
            if (_capturedImage != null) ...[
              const Text(
                'Your Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController, // ✅ Now auto-updating
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
            ],

            /// Description
            const Text(
              'Describe the incident...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _incidentDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the incident',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            /// Submit button
            ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3182CE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
