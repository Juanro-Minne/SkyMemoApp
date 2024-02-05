import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => AppBar().preferredSize;
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromARGB(255, 76, 118, 84),
      foregroundColor: Color.fromARGB(255, 212, 198, 106),
      title: Text('Dashboard'),
      actions: [
        UserProfileIcon(),
      ],
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
