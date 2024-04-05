// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flight_logbook/components/app_bar.dart';
import 'package:flight_logbook/components/bottom_navbar.dart';
import 'package:flight_logbook/screens/log_flights_screen.dart';
import 'package:flight_logbook/screens/dashboard_screen.dart';
import 'package:flight_logbook/screens/documents_screen.dart';
import 'package:flight_logbook/screens/planes_screen.dart';

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

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Log Flights';
      case 2:
        return 'Manage Planes';
      case 3:
        return 'Manage Documents';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: _getTitle(_selectedIndex)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _getBodyWidget(_selectedIndex),
            ),
            BottomNavBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const LogFlightsScreen();
      case 2:
        return const PlanesScreen();
      case 3:
        return const DocumentsScreen();
      default:
        return Container();
    }
  }
}
