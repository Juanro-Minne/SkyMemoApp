import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 76, 118, 84),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 17),
        child: GNav(
          color: Color.fromARGB(255, 212, 198, 106),
          backgroundColor: Color.fromARGB(255, 76, 118, 84),
          activeColor: Color.fromARGB(255, 212, 198, 106),
          tabBackgroundColor: Color.fromARGB(255, 62, 99, 68),
          gap: 7,
          selectedIndex: currentIndex, // Set the selected index
          onTabChange: onTap, // Set the callback function
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
    );
  }
}
