import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:strawberry_diagnosis/home_screen.dart';
import 'package:strawberry_diagnosis/profile_related_screen.dart';
import 'dart:convert';

import 'package:strawberry_diagnosis/scan_page.dart';

enum ResultType {
  fullReport,
  multipleResults,
  notEnoughInfo,
  error,
}

/// Updated model class to match the GraphQL data
class Diagnosis {
  final String id;
  final String imageKey;
  final String diseaseDetected;
  final String fungalStatus;
  final String result;
  final String healthStatus;
  final List<String>? recommendations;
  final DateTime timestamp;

  Diagnosis({
    required this.id,
    required this.imageKey,
    required this.diseaseDetected,
    required this.fungalStatus,
    required this.result,
    required this.healthStatus,
    required this.recommendations,
    required this.timestamp,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'] ?? '',
      imageKey: json['image_key'] ?? '',
      diseaseDetected: json['disease_detected'] ?? '',
      fungalStatus: json['fungal_status'] ?? '',
      result: json['result'] ?? '',
      healthStatus: json['health_status'] ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Diagnosis> _diagnoses = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDiagnoses();
  }

  Future<void> _fetchDiagnoses() async {
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

      debugPrint('GraphQL response: ${response.data}');

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
        title: const Text("Results"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _diagnoses.isEmpty
                    ? const Center(child: Text("No diagnoses found."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _diagnoses.length,
                        itemBuilder: (context, idx) {
                          final diag = _diagnoses[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
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
                          );
                        },
                      ),
      ),
    bottomNavigationBar: Container(
							height: 70,
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
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
								children: [
									IconButton(
										icon: const Icon(Icons.home, size: 32, color: Colors.green),
										splashRadius: 28,
										onPressed: () {
											Navigator.of(context).pushAndRemoveUntil(
												MaterialPageRoute(builder: (_) => HomeScreen()),
												(route) => false,
											);
										},
									),
									Container(
										decoration: BoxDecoration(
											color: const Color(0xFFE0F5E9),
											borderRadius: BorderRadius.circular(16),
										),
										child: IconButton(
											icon: const Icon(Icons.apps, size: 32, color: Colors.green),
											splashRadius: 28,
											onPressed: () {
												Navigator.of(context).pushAndRemoveUntil(
													MaterialPageRoute(builder: (_) => ScanPage()),
													(route) => false,
												);
											},
										),
									),
									IconButton(
										icon: const Icon(Icons.person, size: 32, color: Colors.green),
										splashRadius: 28,
										onPressed: () {
											Navigator.of(context).pushAndRemoveUntil(
													MaterialPageRoute(builder: (_) => ProfileRelatedScreen()),
													(route) => false,
											);
										},
									),
								],
							),
						),
			);
  }
}
