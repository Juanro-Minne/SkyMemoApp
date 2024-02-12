import 'package:flight_logbook/components/custom_textfield.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _takeoffLocationController = TextEditingController();
  final _destinationController = TextEditingController();
  final _flightTimeController = TextEditingController();

  String? _selectedPlaneRegistration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Flights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPlaneRegistration,
                  onChanged: (value) {
                    setState(() {
                      _selectedPlaneRegistration = value;
                    });
                  },
                  items: _buildDropdownItems(),
                  decoration: const InputDecoration(labelText: 'Plane Registration'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select plane registration';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _takeoffLocationController,
                  labelText: 'Takeoff Location',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter takeoff location';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _destinationController,
                  labelText: 'Destination',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter destination';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _flightTimeController,
                  labelText: 'Flight Time',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter flight time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _logFlight();
                    }
                  },
                  child: const Text('Log Flight'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    // Fetch plane registrations from Firestore and populate dropdown items
    // For simplicity, assuming planeRegistrations is a List<String> retrieved from Firestore
    List<String> planeRegistrations = ['XYZ789', 'LMN456']; // Example data
    return planeRegistrations
        .map((registration) => DropdownMenuItem(
              value: registration,
              child: Text(registration),
            ))
        .toList();
  }

  void _logFlight() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('flights').add({
          'userId': user.email,
          'planeRegistration': _selectedPlaneRegistration,
          'takeoffLocation': _takeoffLocationController.text,
          'destination': _destinationController.text,
          'flightTime': _flightTimeController.text,
        });

        _takeoffLocationController.clear();
        _destinationController.clear();
        _flightTimeController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flight logged successfully'),
          ),
        );
      }
    } catch (error) {
      // Handle error
    }
  }
}
