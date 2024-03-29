// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flight_logbook/components/flight_logging_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../components/tab.dart';

class FlightData {
  final String takeoffLocation;
  final String destination;
  final double flightTime;
  final String flightDescription;
  final DateTime takeoffTime;

  FlightData({
    required this.takeoffLocation,
    required this.destination,
    required this.flightTime,
    required this.flightDescription,
    required Timestamp takeoffTime,
    required id,
  }) : takeoffTime = takeoffTime.toDate();
}

String _formatDateTime(DateTime dateTime) {
  return DateFormat.yMMMd().add_jm().format(dateTime);
}

class LogFlightsScreen extends StatefulWidget {
  const LogFlightsScreen({Key? key}) : super(key: key);

  @override
  _LogFlightsScreenState createState() => _LogFlightsScreenState();
}

class _LogFlightsScreenState extends State<LogFlightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _flightTimeController = TextEditingController();
  final _planesRegistrationController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TabBar(
                      unselectedLabelColor: Colors.black,
                      labelColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 5,
                      indicator: BoxDecoration(
                        color: const Color.fromARGB(255, 219, 219, 219),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      controller: _tabController,
                      tabs: const [
                        TabCustom(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          text: 'Log Flights',
                        ),
                        TabCustom(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          text: 'View Flights',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFlightLoggingForm(),
                _buildFlightList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFlightList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFlights(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LinearProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final flights = snapshot.data!;
            return ListView.builder(
              itemCount: flights.length,
              itemBuilder: (context, index) {
                final flight = flights[index];
                return Dismissible(
                  key: Key(flight['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 220, 93, 84),
                    ),
                    alignment: AlignmentDirectional.centerEnd,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  onDismissed: (direction) {
                    _deleteFlight(flight['id']);
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 220, 212, 197),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      title: Text(
                        'Flight number: ${index + 1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Takeoff Location: ${flight['takeoffLocation']}',
                            style: const TextStyle(
                                fontSize: 17, color: Colors.black),
                          ),
                          Text(
                            'Destination: ${flight['destination']}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'Flight Time in hours: ${flight['flightTime']}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'Flight Description: ${flight['flightDescription']}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'Takeoff Time: ${_formatDateTime(flight['takeoffTime'].toDate())}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'Plane Registartion: ${flight['planeRegistration']}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          const Text(
                            'note: Swipe left delete flight',
                            style: TextStyle(fontSize: 13, color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteFlight(String flightId) async {
    try {
      await _firestore.collection('flights').doc(flightId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flight deleted successfully'),
          backgroundColor: Color.fromARGB(255, 105, 123, 240),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent.withOpacity(0.7),
          content: Text('Failed to delete flight: $e'),
        ),
      );
    }
  }

  Widget _buildFlightLoggingForm() {
    return FlightLoggingForm(
      fetchPlaneRegistrations: _fetchPlaneRegistrations,
      onLogFlight: _logFlight,
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
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFlights() async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('flights')
            .where('userId', isEqualTo: userEmail)
            .get();

        final flights = querySnapshot.docs.map((doc) {
          Map<String, dynamic> flightData = doc.data();
          flightData['id'] = doc.id;
          return flightData;
        }).toList();
        return flights;
      } else {
        throw Exception('User email was not found');
      }
    } catch (error) {
      rethrow;
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
            const SnackBar(
              content: Text('Flight logged successfully'),
              backgroundColor: Color.fromARGB(255, 105, 123, 240),
              duration: Duration(seconds: 2),
            ),
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
