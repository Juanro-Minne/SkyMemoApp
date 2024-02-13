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
                FutureBuilder<List<String>>(
                  future: _fetchPlaneRegistrations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return DropdownButtonFormField<String>(
                        value: _selectedPlaneRegistration,
                        onChanged: (value) {
                          setState(() {
                            _selectedPlaneRegistration = value;
                          });
                        },
                        items: snapshot.data!.map((registration) {
                          return DropdownMenuItem(
                            value: registration,
                            child: Text(registration),
                          );
                        }).toList(),
                        decoration: const InputDecoration(labelText: 'Plane Registration'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select plane registration';
                          }
                          return null;
                        },
                      );
                    }
                  },
                ),
                SizedBox(height: 16.0),
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

  Future<List<String>> _fetchPlaneRegistrations() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('planes').get();
      List<String> planeRegistrations = querySnapshot.docs
          .map((doc) => doc['planeRegistration'] as String)
          .toList();
      return planeRegistrations;
    } catch (error) {
      throw error;
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log flight: $error')
        ),
      );
    }
  }
}
