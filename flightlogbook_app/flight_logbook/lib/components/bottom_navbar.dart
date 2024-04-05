// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // ignore: deprecated_member_use
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !_isKeyboardVisible,
      child: Container(
        color: const Color.fromARGB(255, 76, 118, 84),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
          child: GNav(
            color: const Color.fromARGB(255, 212, 198, 106),
            backgroundColor: const Color.fromARGB(255, 76, 118, 84),
            activeColor: const Color.fromARGB(255, 212, 198, 106),
            tabBackgroundColor: const Color.fromARGB(255, 62, 99, 68),
            gap: 7,
            selectedIndex: widget.currentIndex,
            onTabChange: widget.onTap,
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
