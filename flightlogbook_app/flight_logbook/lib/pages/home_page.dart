import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_logbook/components/app_bar.dart';
import 'package:flight_logbook/pages/documents_page.dart';
import 'package:flight_logbook/pages/logFlights_page.dart';
import 'package:flight_logbook/pages/planes_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Add this line to keep track of the selected tab

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // Add a function to handle navigation to different pages
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
       
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogFlights()),
        );
        break;
      case 2:
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogPlanes()),
        );
        break;
      case 3:
        // Navigate to Documents page
        // Replace DocumentsPage() with your actual documents page widget
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Documents()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: MyAppBar(),
      body: Container(
        // Add a body if needed
      ),
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 76, 118, 84),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 17),
          child: GNav(
            color: Color.fromARGB(255, 212, 198, 106),
            backgroundColor: Color.fromARGB(255, 76, 118, 84),
            activeColor: Color.fromARGB(255, 212, 198, 106),
            tabBackgroundColor: Color.fromARGB(255, 62, 99, 68),
            gap: 7,
            selectedIndex: _selectedIndex, // Set the selected index
            onTabChange: _onItemTapped, // Set the callback function
            tabs: const [
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
            ],
          ),
        ),
      ),
    );
  }
}
