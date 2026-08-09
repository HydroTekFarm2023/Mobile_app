import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:strawberry_diagnosis/resultpage.dart';
import 'package:strawberry_diagnosis/diagnosis_detail.dart';
import 'dart:convert';

class SavedScansPage extends StatefulWidget {
  const SavedScansPage({super.key});

  @override
  State<SavedScansPage> createState() => _SavedScansPageState();
}

class _SavedScansPageState extends State<SavedScansPage> {
  List<Diagnosis> _diagnoses = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSavedDiagnoses();
  }

  Future<void> _fetchSavedDiagnoses() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    const String graphQLDocument = '''
    query ListDiagnoses {
      listDiagnoses {
        items {
          id
          image_key
          disease_detected
          fungal_status
          health_status
          result
          recommendations
          timestamp
        }
      }
    }
    ''';

    try {
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        authorizationMode: APIAuthorizationType.userPools,
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.data == null) {
        setState(() {
          _diagnoses = [];
          _loading = false;
          _error = 'No data received.';
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
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Query failed: $e';
        _diagnoses = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Saved Scans"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _diagnoses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text(
                              "No saved scans yet",
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Scan a plant to save results",
                              style: TextStyle(fontSize: 14, color: Colors.black45),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _diagnoses.length,
                        itemBuilder: (context, idx) {
                          final diag = _diagnoses[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DiagnosisDetailPage(diagnosis: diag),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Color(0xFFD9F2E6),
                                          child: Icon(Icons.local_florist, color: Colors.green),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            diag.diseaseDetected.isNotEmpty
                                                ? diag.diseaseDetected
                                                : "Unknown Disease",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ),
                                        if (diag.healthStatus.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              diag.healthStatus,
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    if (diag.result.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          diag.result,
                                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                                        ),
                                      ),
                                    if (diag.fungalStatus.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Fungal Status: ",
                                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                            Expanded(
                                              child: Text(
                                                diag.fungalStatus,
                                                style: const TextStyle(color: Colors.black87),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Text(
                                      "Date: ${diag.timestamp.toLocal().toString().split(' ').first}",
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
