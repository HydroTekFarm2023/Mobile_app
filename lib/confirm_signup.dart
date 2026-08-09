import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'login_screen_v2.dart';

class ConfirmSignUpPage extends StatefulWidget {
  const ConfirmSignUpPage({super.key});

  @override
  State<ConfirmSignUpPage> createState() => _ConfirmSignUpPageState();
}

class _ConfirmSignUpPageState extends State<ConfirmSignUpPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  String? _emailError;
  String? _codeError;
  bool _loading = false;
  String? _authError;

  Future<void> _confirmSignUp() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    setState(() {
      _emailError = email.isEmpty ? 'Please enter your email.' : null;
      _codeError = code.isEmpty ? 'Please enter the confirmation code.' : null;
    });

    if (_emailError != null || _codeError != null) return;

    setState(() => _loading = true);
    try {
      await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: code,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email confirmed successfully!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPageV2()),
        );
      }
    } on AuthException catch (e) {
      setState(() => _authError = e.message);
    } catch (e) {
      setState(() => _authError = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email first.');
      return;
    }

    setState(() => _loading = true);
    try {
      await Amplify.Auth.resendSignUpCode(username: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code resent successfully!')),
        );
      }
    } on AuthException catch (e) {
      setState(() => _authError = e.message);
    } catch (e) {
      setState(() => _authError = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF7),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Image(image: AssetImage('images/logo.jpg'), height: 110),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4EC),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Confirm Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    const Text('Email', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    if (_emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(_emailError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    const SizedBox(height: 20),
                    const Text('Confirmation Code', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: 'Enter the 6-digit code...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    if (_codeError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(_codeError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    if (_authError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_authError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _confirmSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3BA05B),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Confirm', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loading ? null : _resendCode,
                      child: const Text(
                        "Resend code",
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
