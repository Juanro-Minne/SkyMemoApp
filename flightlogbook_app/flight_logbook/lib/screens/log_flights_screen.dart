import 'package:flight_logbook/components/custom_textfield.dart';
import 'package:flight_logbook/components/flight_logging_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_logbook/components/my_button.dart';

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
                onLogFlight: _logFlight,
                fetchPlaneRegistrations: _fetchPlaneRegistrations,
              ),
          ],
        ),
      ),
    );
  }
}
