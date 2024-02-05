import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_logbook/components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: MyAppBar(),
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 76, 118, 84),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 17),
          child: GNav(
              color: Color.fromARGB(255, 212, 198, 106),
              backgroundColor: Color.fromARGB(255, 76, 118, 84),
              activeColor: Color.fromARGB(255, 212, 198, 106),
              tabBackgroundColor: Color.fromARGB(255, 62, 99, 68),
              gap: 7,
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.book,
                  text: 'Log Flights',
                ),
                GButton(
                  icon: Icons.airplanemode_active_outlined,
                  text: 'Planes',
                ),
                GButton(
                  icon: Icons.list,
                  text: 'Documents',
                ),
              ]),
        ),
      ),
    );
  }
}
