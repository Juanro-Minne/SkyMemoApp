import 'package:flutter/material.dart';
import 'package:flight_logbook/components/custom_textfield.dart';
import 'package:flight_logbook/components/my_button.dart';

class FlightLoggingForm extends StatefulWidget {
  final Future<List<String>> Function() fetchPlaneRegistrations;
  final void Function({
    required String takeoffLocation,
    required String destination,
    required String planeRegistration,
    required int flightTime,
    required String flightDescription,
    required DateTime takeoffTime, // Include takeoffTime field
  }) onLogFlight;

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
  late DateTime _selectedTakeoffTime;

  @override
  void initState() {
    super.initState();
    _selectedTakeoffTime = DateTime.now();
  }

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
                    return const LinearProgressIndicator();
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
                hintText: 'Enter your flight duration',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter flight duration';
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
              const SizedBox(height: 10),
              Text('Takeoff Time: ${_formatDateTime(_selectedTakeoffTime)}'),
              ElevatedButton(
                onPressed: () {
                  _showDateTimePicker(context);
                },
                child: const Text('Select Takeoff Time'),
              ),
              const SizedBox(height: 8.0),
              MyButton(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onLogFlight(
                      takeoffLocation: _takeoffLocationController.text.trim(),
                      destination: _destinationController.text.trim(),
                      planeRegistration: _selectedPlaneRegistration!,
                      flightTime: int.parse(_flightTimeController.text.trim()),
                      flightDescription: _flightDescription.text.trim(),
                      takeoffTime: _selectedTakeoffTime,
                    );
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTakeoffTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedTakeoffTime) {
      setState(() {
        _selectedTakeoffTime = picked; // Update selected takeoff time
      });
    }
  }
}
