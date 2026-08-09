//import 'package:strawberry_diagnosis/login_screen.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:strawberry_diagnosis/amplifyconfiguration.dart';
import 'package:strawberry_diagnosis/login_screen_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

final amplifyConfiguredProvider = FutureProvider<bool>((ref) async {
  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(),
      AmplifyStorageS3(),
    ]);
    await Amplify.configure(amplifyconfig);
    return true;
  } catch (e) {
    print('Failed to configure Amplify: $e');
    return false;
  }
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: StrawberryDiagnosisApp()));
}

class StrawberryDiagnosisApp extends StatelessWidget {
  const StrawberryDiagnosisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strawberry Diagnosis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AmplifyInitializer(),
    );
  }
}

class AmplifyInitializer extends ConsumerWidget {
  const AmplifyInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amplifyConfigured = ref.watch(amplifyConfiguredProvider);

    return amplifyConfigured.when(
      data: (configured) {
        if (!configured) {
          return const Scaffold(
            body: Center(child: Text('Failed to configure Amplify')),
          );
        }
        return const SessionChecker();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}

class SessionChecker extends StatelessWidget {
  const SessionChecker({super.key});

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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const HomeScreen() : const LoginPageV2();
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
