// ignore_for_file: use_build_context_synchronously, file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_logbook/components/app_bar.dart';
import 'package:flight_logbook/components/custom_button.dart';
import 'package:flight_logbook/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const ForgotPasswordPage({Key? key, required this.showLoginPage})
      : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Password reset link sent! Please check email'),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent.withOpacity(0.7),
          content: Text('Failed to reset password: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Forgot Password'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your recovery email to reset password:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: passwordReset,
              description: 'Reset Password',
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
