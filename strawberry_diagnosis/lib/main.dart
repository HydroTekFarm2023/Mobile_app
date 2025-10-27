//import 'package:strawberry_diagnosis/login_screen.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:strawberry_diagnosis/amplifyconfiguration.dart';
import 'package:strawberry_diagnosis/login_screen_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

import 'package:flutter/material.dart';
// GraphQL API

Future<void> configureAmplify() async {
  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(),
      AmplifyStorageS3(),
    ]);
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print('Failed to configure Amplify: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase (some screens still use Firebase APIs)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If Firebase isn't configured for the current platform, log and continue.
    print('Firebase initialization warning: $e');
  }

  // Ensure Amplify is configured before running the app
  await configureAmplify();

  runApp(const StrawberryDiagnosisApp());
}


class StrawberryDiagnosisApp extends StatefulWidget {
  const StrawberryDiagnosisApp({super.key});

  @override
  State<StrawberryDiagnosisApp> createState() => _StrawberryDiagnosisAppState();
}

class _StrawberryDiagnosisAppState extends State<StrawberryDiagnosisApp> {
  Future<bool> _hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    return email != null && email.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MaterialApp(
          title: 'Strawberry Diagnosis',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.green),
          home: snapshot.data! ? const HomeScreen() : const LoginPageV2(),
        );
      },
    );
  }
}

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
