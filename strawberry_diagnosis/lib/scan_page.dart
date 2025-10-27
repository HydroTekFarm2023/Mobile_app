import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strawberry_diagnosis/resultpage.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ))
      ..addListener(() => setState(() {}));

    // Repeat infinitely to simulate scanning
    _animationController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera =
        cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(backCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final image = await _cameraController!.takePicture();
      debugPrint("Captured Image Path: ${image.path}");
      // Handle navigation or image upload here
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ResultPage()),
        (route) => false,
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint("Picked Image Path: ${image.path}");
      // Handle navigation or processing here
    }
  }

  Widget _bottomIcon(IconData icon, Color color, VoidCallback onPressed) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 26),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCameraMarkers() {
    return IgnorePointer(
      child: Center(
        child: CustomPaint(
          size: const Size(240, 240),
          painter: _CornerPainter(),
        ),
      ),
    );
  }

  Widget _buildScanEffect() {
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            children: [
              Positioned(
                top: 240 * _animation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.greenAccent,
                        Colors.transparent,
                      ],
                      stops: const [0.1, 0.5, 0.9],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Scan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.help_outline, color: Colors.black),
          )
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraInitialized)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator()),

          // Overlay markers
          if (_isCameraInitialized) _buildCameraMarkers(),

          // Scanning laser effect
          if (_isCameraInitialized) _buildScanEffect(),

          // Cancel button
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Cancel"),
                ),
              ),
            ),
          ),

          // Bottom toolbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bottomIcon(Icons.photo, Colors.green, _pickFromGallery),
                  _bottomIcon(Icons.camera_alt, Colors.black, _captureImage),
                  _bottomIcon(Icons.refresh, Colors.green, _captureImage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter for corner brackets
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const double corner = 30;

    // Top-left
    canvas.drawLine(Offset(0, 0), Offset(corner, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, corner), paint);

    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - corner, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, corner), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(corner, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - corner), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - corner, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - corner), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
