import 'package:flight_logbook/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flight_logbook/components/custom_textfield.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PlaneLoggingForm extends StatefulWidget {
  final void Function({
    required String registration,
    required String engineType,
    required int totalHours,
    required File? imageFile,
  }) onAddPlane;

  const PlaneLoggingForm({Key? key, required this.onAddPlane})
      : super(key: key);

  @override
  _PlaneLoggingFormState createState() => _PlaneLoggingFormState();
}

class _PlaneLoggingFormState extends State<PlaneLoggingForm> {
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _totalHoursController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(10.0),
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          CustomTextField(
            controller: _registrationController,
            labelText: 'Registration',
            hintText: 'Registration',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter plane Registration:ex: ZS-ABC';
              }
              return null;
            },
          ),
          const SizedBox(height: 10.0),
          CustomTextField(
            controller: _engineTypeController,
            labelText: 'Engine Type',
            hintText: 'Enter Engine type',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter plane engine type';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _totalHoursController,
            labelText: 'Total Hours',
            hintText: 'Enter total hours on Plane',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total hours';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: const Text('Pick Image'),
              ),
              const SizedBox(width: 16.0),
              _imageFile != null
                  ? Text(_imageFile!.path)
                  : const Text('No image selected'),
            ],
          ),
          const SizedBox(height: 8.0),
          MyButton(
            onTap: () async {
              if (_formKey.currentState!.validate()) {
                String registration = _registrationController.text.trim();
                String engineType = _engineTypeController.text.trim();
                int totalHours = int.parse(_totalHoursController.text.trim());

                widget.onAddPlane(
                  registration: registration,
                  engineType: engineType,
                  totalHours: totalHours,
                  imageFile: _imageFile,
                );
              }
            },
            description: "Log flight",
          ),
        ],
      ),
    ));
  }
}
