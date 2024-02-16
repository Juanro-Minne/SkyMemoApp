import 'package:flight_logbook/components/flight_logging_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogFlightsScreen extends StatefulWidget {
  const LogFlightsScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LogFlightsScreenState createState() => _LogFlightsScreenState();
}

class _LogFlightsScreenState extends State<LogFlightsScreen> {
  bool _showForm = false;
  final _flightTimeController = TextEditingController();
  final _planesRegistrationController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedPlaneRegistration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Flights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showForm = !_showForm;
                });
              },
              child: Text(_showForm ? 'Hide Form' : 'Log New Flight'),
            ),
            if (_showForm)
              FlightLoggingForm(
                fetchPlaneRegistrations: _fetchPlaneRegistrations,
                onLogFlight: _logFlight,
              ),
          ],
        ),
      ),
    );
  }
  Future<List<String>> _fetchPlaneRegistrations() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('planes').get();
      List<String> planeRegistrations = querySnapshot.docs
          .map((doc) => doc['registration'] as String)
          .toList();
      return planeRegistrations;
    } catch (error) {
      throw error;
    }
  }

  void _logFlight() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? planeRegistration = _selectedPlaneRegistration;
        int flightTime = int.parse(_flightTimeController.text);

        if (planeRegistration != null) {
          QuerySnapshot planeSnapshot = await _firestore
              .collection('planes')
              .where('registration', isEqualTo: planeRegistration)
              .get();
          if (planeSnapshot.docs.isNotEmpty) {
            DocumentSnapshot planeDoc = planeSnapshot.docs.first;
            int currentTotalHours = planeDoc['totalHours'] ?? 0;
            int newTotalHours = currentTotalHours + flightTime;

            // Update the plane document with the new total hours
            await FirebaseFirestore.instance
                .collection('planes')
                .doc(planeDoc.id)
                .update({
              'totalHours': newTotalHours,
            });

            _planesRegistrationController.clear();
            _flightTimeController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Flight logged successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plane not found')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent.withOpacity(0.7),
          content: Text('Failed to log flight: $e'),
        ),
      );
    }
  }
}
