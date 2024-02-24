import 'package:flutter/material.dart';
import 'package:flight_logbook/components/flight_logging_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../components/custom_tabbar.dart';
import '../components/tab.dart';

class FlightData {
  final String takeoffLocation;
  final String destination;
  final int flightTime;
  final String flightDescription;
  final DateTime takeoffTime;

  FlightData({
    required this.takeoffLocation,
    required this.destination,
    required this.flightTime,
    required this.flightDescription,
    required Timestamp takeoffTime,
  }) : takeoffTime = takeoffTime.toDate();
}

String _formatDateTime(DateTime dateTime) {
  return DateFormat.yMMMd().add_jm().format(dateTime);
}

class FlightDataSource extends DataTableSource {
  final List<FlightData> flightData;

  FlightDataSource({required this.flightData});

  @override
  DataRow? getRow(int index) {
    if (index >= flightData.length) {
      return null;
    }
    final flight = flightData[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(flight.takeoffLocation)),
        DataCell(Text(flight.destination)),
        DataCell(Text('${flight.flightTime}')),
        DataCell(Text(flight.flightDescription)),
        DataCell(Text(_formatDateTime(flight.takeoffTime))),
      ],
    );
  }

  @override
  int get rowCount => flightData.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
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
                        color: const Color.fromARGB(255, 219, 219,
                            219), // Set color for the pill indicator
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final flights = snapshot.data!;
            final flightData = flights.map((flight) {
              return FlightData(
                takeoffLocation: flight['takeoffLocation'] ?? '',
                destination: flight['destination'] ?? '',
                flightTime: flight['flightTime'] ?? 0,
                flightDescription: flight['flightDescription'] ?? '',
                takeoffTime: flight['takeoffTime'] ?? DateTime.now(),
              );
            }).toList();

            return ListView.builder(
              itemCount: flightData.length,
              itemBuilder: (context, index) {
                final flight = flightData[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 243, 202, 128),
                  ), // Set tile background color
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    title: Text('Flight ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Takeoff Location: ${flight.takeoffLocation}'),
                        Text('Destination: ${flight.destination}'),
                        Text('Flight Time (hours): ${flight.flightTime}'),
                        Text('Flight Description: ${flight.flightDescription}'),
                        Text(
                            'Takeoff Time: ${_formatDateTime(flight.takeoffTime)}'),
                      ],
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
        final flights = querySnapshot.docs.map((doc) => doc.data()).toList();
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
