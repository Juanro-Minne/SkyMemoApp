import 'package:flight_logbook/pages/forgot_pass_page.dart';
import 'package:flight_logbook/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Initially show login
  bool showLoginPage = true;

  // Show whatever page it is not on when clicked
  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  // Function to navigate to the forgot password page
  void navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(
          // Pass toggleScreens as a callback to navigate back to login page
          showLoginPage: toggleScreens,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        // Pass the navigateToForgotPassword function to LoginPage
        showRegisterpage: toggleScreens,
        showForgotPasspage: navigateToForgotPassword,
      );
    } else {
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
