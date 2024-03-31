// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_logbook/components/data_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalFlights = 0;
  int _lastFlightTime = 0;
  late String _lastTakeoffTime;
  late String? _lastDestination;
  List<Widget> expiryWarningCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _lastDestination = 'N/A';
    _lastTakeoffTime = 'N/A';
    _populateData();
    _checkExpiryWarnings();
  }

  Future<void> _populateData() async {
    await Future.wait([
      _populateLastFlightTime(),
      _populateTotalFlights(),
      _populateLastTakeoffTime(),
      _populateLastDestination(),
    ]);
    List<Widget> warnings = await _checkExpiryWarnings();
    setState(() {
      expiryWarningCards = warnings;
      _isLoading = false;
    });
  }

  Future<void> _populateLastFlightTime() async {
    int lastFlightTime = await getLastFlightTime();
    setState(() {
      _lastFlightTime = lastFlightTime;
    });
  }

  Future<void> _populateTotalFlights() async {
    int totalFlights = await getTotalFlights();
    setState(() {
      _totalFlights = totalFlights;
    });
  }

  Future<void> _populateLastTakeoffTime() async {
    String lastTakeoffTime = await getLastTakeoffTime();
    setState(() {
      _lastTakeoffTime = lastTakeoffTime;
    });
  }

  Future<void> _populateLastDestination() async {
    String lastDestination = await getLastDestination();
    setState(() {
      _lastDestination = lastDestination;
    });
  }

  Future<List<Widget>> _checkExpiryWarnings() async {
    List<Widget> expiryWarningCards = [];
    DateTime currentDate = DateTime.now();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('documents')
          .where('expiryDate', isGreaterThan: Timestamp.fromDate(currentDate))
          .get();

      querySnapshot.docs.forEach((doc) {
        Timestamp expiryTimestamp = doc['expiryDate'] as Timestamp;
        DateTime expiryDate = expiryTimestamp.toDate();

        int daysUntilExpiry = expiryDate.difference(currentDate).inDays;
        if (daysUntilExpiry <= 30) {
          String fileName = doc['fileName'] as String;

          Widget expiryCard = Card(
            child: ListTile(
              title: Text('Document: $fileName'),
              subtitle: Text('Expires in $daysUntilExpiry days'),
            ),
          );
          expiryWarningCards.add(expiryCard);
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error chacking expiry warnings'),
          backgroundColor: Color.fromARGB(255, 231, 85, 85),
          duration: Duration(seconds: 3),
        ),
      );
    }
    return expiryWarningCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blueGrey,
                  image: const DecorationImage(
                    image: AssetImage('lib/images/backround2.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: InkWell(
                  onTap: null,
                  borderRadius: BorderRadius.circular(20),
                  child: const Center(
                    child: Text(
                      "Welcome Back !",
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DataTile(
                    title: "Last Flight Time",
                    value: _lastFlightTime.toString(),
                    backgroundColor: const Color.fromARGB(255, 201, 192, 192),
                  ),
                  DataTile(
                    title: "Total Flights",
                    value: _totalFlights.toString(),
                    backgroundColor: const Color.fromARGB(255, 201, 192, 192),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DataTile(
                    title: "Last Destination",
                    value: _lastDestination != null ? _lastDestination! : 'N/A',
                    backgroundColor: const Color.fromARGB(255, 201, 192, 192),
                  ),
                  DataTile(
                    title: "Last Takeoff",
                    value: _lastTakeoffTime.toString(),
                    backgroundColor: const Color.fromARGB(255, 201, 192, 192),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.blueGrey,
                thickness: 2,
              ),
              const Row(
                children: [
                  Center(
                    child: Icon(
                      Icons.warning,
                      color: Color.fromARGB(255, 215, 66, 66),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 10),
                  Center(
                    child: Text(
                      "Expiration Warnings:",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Colors.blueGrey,
                thickness: 2,
              ),
              _isLoading
                  ? const SpinKitHourGlass(color: Color.fromARGB(255, 255, 196, 85))
                  : SizedBox(
                      height: 200,
                      child: ListView(
                        shrinkWrap: true,
                        children: expiryWarningCards.isNotEmpty
                            ? expiryWarningCards
                            : [
                                const ListTile(
                                  title: Text('No expiry warnings'),
                                ),
                              ],
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Future<int> getLastFlightTime() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('flights')
            .where('userId', isEqualTo: user.email)
            .orderBy(FieldPath.documentId, descending: true)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first['flightTime'] as int;
        } else {
          return 0;
        }
      } catch (error) {
        return 0;
      }
    } else {
      return 0;
    }
  }

  Future<int> getTotalFlights() async {
    User? user = FirebaseAuth.instance.currentUser;
    int totalFlights = 0;

    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('flights')
            .where('userId', isEqualTo: user.email)
            .get();

        totalFlights = querySnapshot.size;
      } catch (error) {
        print('Error getting total flights: $error');
      }
    }
    return totalFlights;
  }

  Future<String> getLastTakeoffTime() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('flights')
            .where('userId', isEqualTo: user.email)
            .orderBy(FieldPath.documentId, descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          Timestamp timestamp =
              querySnapshot.docs.first['takeoffTime'] as Timestamp;

          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
            timestamp.millisecondsSinceEpoch,
          );
          String formattedDateTime =
              DateFormat('dd-MM-yyyy HH:mm').format(dateTime);

          return formattedDateTime;
        } else {
          return 'No takeoff time found';
        }
      } catch (error) {
        return 'Error getting last takeoff time';
      }
    } else {
      return 'No user signed in';
    }
  }

  Future<String> getLastDestination() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('flights')
            .where('userId', isEqualTo: user.email)
            .orderBy(FieldPath.documentId, descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first['destination'] as String;
        } else {
          return 'No destination found';
        }
      } catch (error) {
        return 'No destination found';
      }
    } else {
      return 'No destination found';
    }
  }
}
