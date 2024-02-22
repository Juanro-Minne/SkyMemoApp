import 'package:flutter/material.dart';
import 'package:flight_logbook/components/custom_textfield.dart';
import 'package:flight_logbook/components/my_button.dart';

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
  String? _selectedPlaneRegistration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<String>>(
                future: widget.fetchPlaneRegistrations(),
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
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        labelText: 'Plane Registration',
                      ),
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
              const SizedBox(height: 10.0),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              CustomTextField(
                controller: _flightDescription,
                labelText: 'Flight Description',
                hintText: 'Enter your flight description',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter flight description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              MyButton(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onLogFlight();
                  }
                },
                description: "Log flight",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
