import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flight_logbook/components/data_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: getLastFlightTime(), // Fetch last flight time asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while fetching data
        } else if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Show error if fetching data fails
        } else {
          final lastFlightTime = snapshot.data;

          return Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(15.0),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome Back !",
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DataTile(
                          title: "Total Hours",
                          value: "958",
                          backgroundColor: Color.fromARGB(255, 129, 129, 129),
                        ),
                        DataTile(
                          title: "Flights Month",
                          value: "12",
                          backgroundColor: Color.fromARGB(255, 129, 129, 129),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DataTile(
                          title: "Last Flight Time",
                          value: lastFlightTime != null
                              ? "$lastFlightTime"
                              : "N/A",
                          backgroundColor:
                              const Color.fromARGB(255, 129, 129, 129),
                        ),
                        const DataTile(
                          title: "Prop hours",
                          value: "29",
                          backgroundColor: Color.fromARGB(255, 129, 129, 129),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<int?> getLastFlightTime() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('flights')
            .where('userId', isEqualTo: user)
            .orderBy('flightTime', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first['flightTime'];
        } else {
          return null;
        }
      } catch (error) {
        print('Error getting last flight time: $error');
        return null;
      }
    } else {
      // No user is currently signed in
      return null;
    }
  }
}
