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
    required DateTime takeoffTime,
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
      body: SingleChildScrollView(
        child: Padding(
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
                      final uniqueRegistrations =
                          snapshot.data!.toSet().toList();

                      return DropdownButtonFormField<String>(
                        value: _selectedPlaneRegistration,
                        onChanged: (value) {
                          setState(() {
                            _selectedPlaneRegistration = value;
                          });
                        },
                        items: uniqueRegistrations.map((registration) {
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
                  hintText: 'Enter takeoff location',
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
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showDateTimePicker(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: Colors.blueGrey,
                          foregroundColor:
                              const Color.fromARGB(255, 245, 228, 178),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 12),
                            Text(
                              'Select Takeoff Time',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Takeoff Time: ${_formatDateTime(_selectedTakeoffTime)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.blueGrey,
                  thickness: 1,
                ),
                const SizedBox(height: 2.0),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: MyButton(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onLogFlight(
                          takeoffLocation:
                              _takeoffLocationController.text.trim(),
                          destination: _destinationController.text.trim(),
                          planeRegistration: _selectedPlaneRegistration!,
                          flightTime:
                              int.parse(_flightTimeController.text.trim()),
                          flightDescription: _flightDescription.text.trim(),
                          takeoffTime: _selectedTakeoffTime,
                        );
                      }
                    },
                    description: "Log flight",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: MyButton(
                    onTap: () {
                      _takeoffLocationController.clear();
                      _destinationController.clear();
                      _flightTimeController.clear();
                      _flightDescription.clear();
                    },
                    description: "Clear",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTakeoffTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }
}
