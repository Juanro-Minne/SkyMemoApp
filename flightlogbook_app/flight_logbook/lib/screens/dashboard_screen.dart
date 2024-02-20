import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showFlights = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showFlights ? 'Flights' : 'Planes'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20), 
          ToggleButtons(
            isSelected: [_showFlights, !_showFlights],
            onPressed: (int index) {
              setState(() {
                _showFlights = index == 0; 
              });
            },
            children: const [
              Icon(Icons.airplanemode_active),
              Icon(Icons.flight),
            ],
          ),
          const SizedBox(height: 20), // Leave space between toggle buttons and data
          Expanded(
            child: _showFlights ? _buildFlights() : _buildPlanes(),
          ),
          const SizedBox(height: 20), // Leave space at the bottom for warnings
        ],
      ),
    );
  }

  Widget _buildFlights() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('flights')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(snapshot.data!.docs[index]['flightInfo']),
            );
          },
        );
      },
    );
  }

  Widget _buildPlanes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('planes')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(snapshot.data!.docs[index]['planeInfo']),
            );
          },
        );
      },
    );
  }
}
