import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strawberry_diagnosis/resultpage.dart';
import 'package:path/path.dart' as p;
import 'package:strawberry_diagnosis/chatbot_floating_panel.dart';
import 'dart:io';

class ScanPage extends StatefulWidget {
  final String? plantName;
  const ScanPage({super.key, this.plantName});

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
  if (_cameraController == null || !_cameraController!.value.isInitialized) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Camera is not ready")),
    );
    return;
  }

  try {
    final XFile image = await _cameraController!.takePicture();

    // Open preview screen instead of uploading immediately
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewPage(
          imagePath: image.path,
          onAnalyze: () async {
  await _uploadSelectedImage(image.path);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const ResultPage(),
    ),
  );
},
        ),
      ),
    );
  } catch (e) {
    debugPrint("Camera Error: $e");
  }
}
// Show loading dialog



  
Future<void> _pickFromGallery() async {
  final XFile? image =
      await _picker.pickImage(source: ImageSource.gallery);

  if (image == null) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ImagePreviewPage(
        imagePath: image.path,
        onAnalyze: () async {
          await _uploadSelectedImage(image.path);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ResultPage(),
            ),
          );
        },
      ),
    ),
  );
}

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF3BA05B)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF3BA05B)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: const Color(0xFFEAF5E6),
      appBar: AppBar(
        title: const Text(
          "Scan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFFEAF5E6),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {
              // Add help functionality here
            },
          ),
        ],
      ),
      body: _isCameraInitialized
    ? Stack(
        children: [

          CameraPreview(_cameraController!),

          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.greenAccent,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          _buildScanEffect(),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                FloatingActionButton(
                  heroTag: "gallery",
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.photo,
                    color: Colors.green,
                  ),
                  onPressed: _pickFromGallery,
                ),

                FloatingActionButton(
                  heroTag: "camera",
                  backgroundColor: Colors.green,
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  onPressed: _captureImage,
                ),

              ],
            ),
          ),

          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.teal,
              child: const Icon(Icons.chat),
              onPressed: (){
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ChatbotFloatingPanel(),
                );
              },
            ),
          )

        ],
      )
    : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _uploadSelectedImage(String path) async {

    final fileKey = 'public/image_${DateTime.now().millisecondsSinceEpoch}${p.extension(path)}';
    try {
      // Fetch the user ID from Amplify Auth
      final user = await Amplify.Auth.getCurrentUser();
      final userId = user.userId;
      debugPrint('Uploading image for userId: $userId');
      // Upload the image to S3 with user metadata
      await Amplify.Storage.uploadFile(
        path: StoragePath.fromString(fileKey),
        localFile: AWSFile.fromPath(path),
        options: StorageUploadFileOptions(
          metadata: {
            'userId': userId, // Pass userId as metadata
            if (widget.plantName != null) 'plantName': widget.plantName!,
          },
        ),
      ).result;

      final fileUrl = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(fileKey),
      ).result;
      debugPrint('File uploaded successfully. URL: ${fileUrl.url}');
    } catch (e) {
      debugPrint('Failed to upload image: $e');
    }
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
class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  final Future<void> Function() onAnalyze;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Retake"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => const Center(
    child: CircularProgressIndicator(),
  ),
);

await onAnalyze();

                    },
                    child: const Text("Analyze"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}