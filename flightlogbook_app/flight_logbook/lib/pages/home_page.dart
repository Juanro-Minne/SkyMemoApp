import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_logbook/components/app_bar.dart';
import 'package:flight_logbook/components/bottom_navbar.dart';
import 'package:flight_logbook/pages/main_page.dart';
import 'package:flight_logbook/screens/LogFlightsScreen.dart';
import 'package:flight_logbook/screens/dashboardScreen.dart';
import 'package:flight_logbook/screens/documentsScreen.dart';
import 'package:flight_logbook/screens/planesScreen.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

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
      appBar: MyAppBar(),
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
        return LogFlightsScreen();
      case 2:
        return PlanesScreen();
      case 3:
        return DocumentsScreen();
      default:
        return Container(); // Placeholder widget for unknown index
    }
  }
}
