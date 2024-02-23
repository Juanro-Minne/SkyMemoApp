import 'package:flutter/material.dart';
import 'package:flight_logbook/components/flight_logging_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogFlightsScreen extends StatefulWidget {
  const LogFlightsScreen({Key? key}) : super(key: key);

  @override
  _LogFlightsScreenState createState() => _LogFlightsScreenState();
}

class _LogFlightsScreenState extends State<LogFlightsScreen> {
  bool _showForm = false;
  final _flightTimeController = TextEditingController();
  final _planesRegistrationController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide the keyboard and navigation when tapped outside the text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showForm = !_showForm;
                      });
                    },
                    child: Text(_showForm ? 'Hide Form' : 'Log New Flight'),
                  ),
                ),
                const SizedBox(
                    height:
                        10), // Add spacing between the button and the caption
                const Text(
                  'Log your flight details below:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                    height: 10), // Add spacing between the caption and the form
                if (_showForm)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: FlightLoggingForm(
                      fetchPlaneRegistrations: _fetchPlaneRegistrations,
                      onLogFlight: _logFlight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> _fetchPlaneRegistrations() async {
    try {
      String? userEmail = _auth.currentUser?.email;

      if (userEmail != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('planes')
            .where('userId', isEqualTo: userEmail)
            .get();
        List<String> planeRegistrations = querySnapshot.docs
            .map((doc) => doc['registration'] as String)
            .toList();
        return planeRegistrations;
      } else {
        throw Exception('User email was not found');
      }
    } catch (error) {
      throw error;
    }
  }

  void _logFlight({
    required String takeoffLocation,
    required String destination,
    required String planeRegistration,
    required int flightTime,
    required String flightDescription,
    required DateTime takeoffTime,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Set userId to the logged-in user's email
        String userId = user.email ?? '';

        await _firestore.collection('flights').add({
          'userId': userId,
          'takeoffLocation': takeoffLocation,
          'destination': destination,
          'planeRegistration': planeRegistration,
          'flightTime': flightTime,
          'flightDescription': flightDescription,
          'takeoffTime': takeoffTime,
        });

        QuerySnapshot planeSnapshot = await _firestore
            .collection('planes')
            .where('registration', isEqualTo: planeRegistration)
            .get();
        if (planeSnapshot.docs.isNotEmpty) {
          DocumentSnapshot planeDoc = planeSnapshot.docs.first;
          int currentTotalHours = planeDoc['totalHours'] ?? 0;
          int newTotalHours = currentTotalHours + flightTime;
          await _firestore.collection('planes').doc(planeDoc.id).update({
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
