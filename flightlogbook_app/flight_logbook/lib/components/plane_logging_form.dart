import 'package:flutter/material.dart';
import 'package:flight_logbook/components/custom_textfield.dart';
class PlaneLoggingForm extends StatefulWidget {
  final void Function({
    required String registration,
    required String engineType,
    required int totalHours,
    required String imageUrl,
  }) onAddPlane;

  const PlaneLoggingForm({Key? key, required this.onAddPlane}) : super(key: key);

  @override
  _PlaneLoggingFormState createState() => _PlaneLoggingFormState();
}

class _PlaneLoggingFormState extends State<PlaneLoggingForm> {
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _totalHoursController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _registrationController,
            labelText: 'Registration',
            hintText: 'Registration',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter plane Registration';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
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
            hintText: 'Enter total hours',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total hours';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _imageUrlController,
            labelText: 'Image',
            hintText: 'Add image',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please upload image of the plane';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Get values from text controllers
                String registration = _registrationController.text.trim();
                String engineType = _engineTypeController.text.trim();
                int totalHours = int.parse(_totalHoursController.text.trim());
                String imageUrl = _imageUrlController.text.trim();

                // Call the onAddPlane function with the collected values
                widget.onAddPlane(
                  registration: registration,
                  engineType: engineType,
                  totalHours: totalHours,
                  imageUrl: imageUrl,
                );
              }
            },
            child: const Text('Add Plane'),
          ),
        ],
      ),
    );
  }
}
