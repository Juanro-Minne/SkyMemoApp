import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Visibility(
          visible: !isKeyboardVisible,
          child: Container(
            color: const Color.fromARGB(255, 76, 118, 84),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 17),
              child: GNav(
                color: const Color.fromARGB(255, 212, 198, 106),
                backgroundColor: const Color.fromARGB(255, 76, 118, 84),
                activeColor: const Color.fromARGB(255, 212, 198, 106),
                tabBackgroundColor: const Color.fromARGB(255, 62, 99, 68),
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
          ),
        );
      },
    );
  }
}
