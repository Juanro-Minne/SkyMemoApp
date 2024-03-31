//import 'package:flight_logbook/components/custom_button.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_logbook/components/my_button.dart';
import 'package:flight_logbook/components/textfield.dart';
import 'package:flight_logbook/components/tile.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();

  Future<void> signUp() async {
    try {
      if (passwordConfirmed()) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Registration Failed'),
              content: const Text(
                  'The email address is already in use by another account.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle other FirebaseAuthExceptions
        //print('Firebase Auth Error: ${e.code}');
      }
    }
  }

  bool passwordConfirmed() {
    if (passwordController.text.trim() == confirmPassController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [SquareTile(imagePath: 'lib/images/logo.png')],
                ),

                const SizedBox(height: 50),

                Text(
                  'Hello There register below!',
                  style: TextStyle(
                    decorationColor: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'email',
                  obscureText: false,
                ),

                const SizedBox(height: 25),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password: 6 characters or more',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: confirmPassController,
                  hintText: 'confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: signUp,
                  description: "Register",
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: () {
                    emailController.clear();
                    passwordController.clear();
                  },
                  description: "Clear",
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member!',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: const Text(
                        'Login here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
