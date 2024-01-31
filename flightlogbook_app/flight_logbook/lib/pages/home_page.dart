import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
   HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          IconButton(onPressed: signUserOut, icon: Icon(Icons.logout)),
          SnackBar(
            content: Text('Login Successful'),
            duration: Duration(seconds: 2), // Adjust the duration as needed
          ),
        ]),
        
        );
  }
}
