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
        return 'Planes';
      case 3:
        return 'Documents';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: _getTitle(_selectedIndex)),
      body: Stack(
        children: [
          _getBodyWidget(_selectedIndex),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.bottomCenter,
            child: BottomNavBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        return const LogFlightsScreen();
      case 2:
        return const PlanesScreen();
      case 3:
        return DocumentsScreen();
      default:
        return Container();
    }
  }
}
