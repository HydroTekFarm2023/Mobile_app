import 'dart:convert';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'main.dart';
import 'scan_page.dart';
import 'profile_related_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  // Color palette from design
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF4C4C4C);
  static const Color black2 = Color(0xFF707070);
  static const Color greenDark = Color(0xFF28824D);
  static const Color green2 = Color(0xFF3CA768);
  static const Color lightGray = Color(0xFFECECEC);
  static const Color darkGrey = Color(0xFF838383);
  static const Color blue2 = Color(0xFF4BB4D6);

  String _status = 'Initializing...';
  List<Diagnosis> _diagnoses = [];
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (!Amplify.isConfigured) {
      setState(() => _status = 'Amplify not configured');
    } else {
      setState(() => _status = 'Amplify already configured');
    }
  }

  Future<void> _uploadSelectedImage() async {
    if (_selectedImage == null) return;
    setState(() => _status = 'Uploading image...');

    final fileKey = 'public/image_${DateTime.now().millisecondsSinceEpoch}${p.extension(_selectedImage!.path)}';
    try {
      // Fetch the user ID from Amplify Auth
      final user = await Amplify.Auth.getCurrentUser();
      final userId = user.userId;

      // Upload the image to S3 with user metadata
      await Amplify.Storage.uploadFile(
        path: StoragePath.fromString(fileKey),
        localFile: AWSFile.fromPath(_selectedImage!.path),
        options: StorageUploadFileOptions(
          metadata: {
            'userId': userId, // Pass userId as metadata
          },
        ),
      ).result;

      final fileUrl = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(fileKey),
      ).result;

      setState(() {
        _status = 'Image uploaded: ${fileUrl.url}';
        _selectedImage = null;
      });

      await _fetchDiagnoses();
    } catch (e) {
      setState(() => _status = 'Failed to upload image: $e');
    }
  }

  void _deleteSelectedImage() {
    setState(() {
      _selectedImage = null;
      _status = 'Selection cleared';
    });
  }

  Future<void> _fetchDiagnoses() async {
    setState(() => _status = 'Fetching diagnoses...');

    const String graphQLDocument = '''
      query ListDiagnoses {
        listDiagnoses {
          items {
            id
            image_key
            disease_detected
            fungal_status
            health_status
            recommendations
            timestamp
          }
        }
      }
      ''';

    try {
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        authorizationMode: APIAuthorizationType.userPools, // Use user token for authentication
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.data == null) {
        setState(() {
          _diagnoses = [];
          _status = 'No data';
        });
        return;
      }

      final decoded = jsonDecode(response.data!);
      final items = (decoded['listDiagnoses']['items'] as List)
          .where((item) => item != null)
          .map((item) => Diagnosis.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _diagnoses = items;
        _status = 'Fetched ${_diagnoses.length} diagnoses';
      });
    } catch (e) {
      setState(() {
        _status = 'Query failed: $e';
        _diagnoses = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('images/logo.jpg'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "HydroTek Farm",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: black,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(context),
      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home, size: 32, color: _selectedTab == 0 ? Colors.green : Colors.grey),
              splashRadius: 28,
              onPressed: () {
                if (_selectedTab != 0) setState(() => _selectedTab = 0);
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: _selectedTab == 1 ? const Color(0xFFE0F5E9) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: Icon(Icons.apps, size: 32, color: _selectedTab == 1 ? Colors.green : Colors.grey),
                splashRadius: 28,
                onPressed: () {
                  if (_selectedTab != 1) {
                    setState(() => _selectedTab = 1);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScanPage()),
                    );
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.person, size: 32, color: _selectedTab == 2 ? Colors.green : Colors.grey),
              splashRadius: 28,
              onPressed: () {
                if (_selectedTab != 2) {
                  setState(() => _selectedTab = 2);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileRelatedScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_selectedTab == 0) {
      // Home
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(children: [
              const TextSpan(
                text: "Welcome ",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: greenDark,
                ),
              ),
              TextSpan(
                text: "UserName!",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: black2,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          const Text(
            "Get insights about plant health instantly",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: black,
            ),
          ),
          const SizedBox(height: 72),
          _buildHeroCard(),
          if (_selectedImage != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImage!.path),
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _uploadSelectedImage,
                  child: const Text("Upload"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _deleteSelectedImage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Scans",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: black,
                ),
              ),
              GestureDetector(
                onTap: _fetchDiagnoses,
                child: const Text(
                  "view full history",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: blue2,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_diagnoses.isEmpty)
            _EmptyScans()
          else
            Column(
              children: _diagnoses.take(3).map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ScanCard(d),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          Text(_status,
              style: const TextStyle(fontSize: 12, color: black2)),
        ],
      );
    } else if (_selectedTab == 1) {
      // History
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Scan History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: black,
            ),
          ),
          const SizedBox(height: 12),
          if (_diagnoses.isEmpty)
            _EmptyScans()
          else
            Column(
              children: _diagnoses.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ScanCard(d),
                );
              }).toList(),
            ),
        ],
      );
    } else if (_selectedTab == 2) {
      // Profile
      return _buildProfile(context);
    } else {
      // Help placeholder
      return const Center(child: Text("Help section coming soon"));
    }
  }

  Widget _buildHeroCard() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage("assets/images/hero_card_picture.jpg"),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(4, 4),
            blurRadius: 8,
            color: Colors.black26,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            color: lightGray.withOpacity(0.3),
            child: const Text(
              "Diagnose Your\nPlants!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 280,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green2,
                foregroundColor: white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              child: const Text("Scan Now"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    // Navigate to the ProfileRelatedScreen when this widget is built
    Future.microtask(() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileRelatedScreen()),
      );
    });
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyScans extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          height: 150,
          width: 150,
          child: Icon(Icons.image_outlined, size: 64, color: Colors.grey),
        ),
        SizedBox(height: 12),
        Text(
          "No Scans Yet!",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4C4C4C),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Start by tapping 'Scan Now'",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF707070),
          ),
        ),
      ],
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard(this.diagnosis);
  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(left: 24, right: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              "assets/images/recent_scan_placeholder.jpg",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diagnosis.diseaseDetected.isNotEmpty
                      ? diagnosis.diseaseDetected
                      : "Plant Name",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF707070),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      diagnosis.timestamp.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      diagnosis.result.isNotEmpty
                          ? diagnosis.result
                          : "Diagnosis?",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF838383),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
