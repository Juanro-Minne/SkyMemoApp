import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flight_logbook/components/custom_textfield.dart';
import 'package:flight_logbook/components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlightLoggingForm extends StatefulWidget {
  final Future<List<String>> Function() fetchPlaneRegistrations;
  final void Function() onLogFlight;

  const FlightLoggingForm({
    Key? key,
    required this.fetchPlaneRegistrations,
    required this.onLogFlight,
  }) : super(key: key);

  @override
  State<FlightLoggingForm> createState() => _FlightLoggingFormState();
}

class _FlightLoggingFormState extends State<FlightLoggingForm> {
  final _formKey = GlobalKey<FormState>();
  final _takeoffLocationController = TextEditingController();
  final _destinationController = TextEditingController();
  final _flightTimeController = TextEditingController();
  final _flightDescription = TextEditingController();
  final _planesRegistrationController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _showTextFields = false;

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
                      return const CircularProgressIndicator();
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
                        decoration: const InputDecoration(
                            labelText: 'Plane Registration'),
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
                const SizedBox(height: 16.0),
                CustomTextField(
                  controller: _takeoffLocationController,
                  labelText: 'Takeoff Location',
                  hintText: 'Enter location',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter takeoff location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _destinationController,
                  labelText: 'Destination',
                  hintText: 'Enter destination',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter destination';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _flightTimeController,
                  labelText: 'Flight Time',
                  hintText: 'Enter your flight time',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter flight time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _flightDescription,
                  labelText: 'Fligth Description',
                  hintText: 'Enter your flight description',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter flight description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                MyButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      ();
                    }
                  },
                  description: "Log flight",
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
          .map((doc) => doc['registration'] as String)
          .toList();
      print('$planeRegistrations');
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
