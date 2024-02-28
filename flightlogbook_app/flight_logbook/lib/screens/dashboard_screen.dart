import 'package:flight_logbook/components/data_tile.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: const [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                "Welcome Back !",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
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
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DataTile(
                    title: "LastFlight Time",
                    value: "6",
                    backgroundColor: Color.fromARGB(255, 129, 129, 129),
                  ),
                  DataTile(
                    title: "Prop hours",
                    value: "29",
                    backgroundColor: Color.fromARGB(255, 129, 129, 129),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
