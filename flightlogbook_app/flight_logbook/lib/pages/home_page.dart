// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_logbook/components/app_bar.dart';
import 'package:flight_logbook/components/bottom_navbar.dart';
import 'package:flight_logbook/screens/log_flights_screen.dart';
import 'package:flight_logbook/screens/dashboard_screen.dart';
import 'package:flight_logbook/screens/documents_screen.dart';
import 'package:flight_logbook/screens/planes_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: _getBodyWidget(_selectedIndex),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(); // Assuming MainPage is your default screen
      case 1:
        return const LogFlightsScreen();
      case 2:
        return PlanesScreen();
      case 3:
        return DocumentsScreen();
      default:
        return Container(); // Placeholder widget for unknown index
    }
  }
}
