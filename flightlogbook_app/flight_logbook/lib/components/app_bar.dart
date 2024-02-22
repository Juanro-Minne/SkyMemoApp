import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const MyAppBar({Key? key, required this.title}) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 76, 118, 84),
      foregroundColor: const Color.fromARGB(255, 212, 198, 106),
      elevation: 0,
      title: Row(
        children: [
          Text(
            widget.title.toUpperCase(), // Dynamically set the title
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: UserProfileIcon(),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(10), // Adjust radius as needed
        ),
      ),
    );
  }
}

class UserProfileIcon extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'settings') {
          // Handle Settings
        } else if (value == 'logout') {
          signUserOut();
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'settings',
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'logout',
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
            ),
          ),
        ];
      },
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.person),
      ),
    );
  }
}
