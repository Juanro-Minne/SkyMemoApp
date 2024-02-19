import 'package:flight_logbook/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({Key? key}) : super(key: key);

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _totalHoursController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addPlane() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('planes').add({
          'userId': user.email,
          'registration': _registrationController.text,
          'engineType': _engineTypeController.text,
          'totalHours': int.parse(_totalHoursController.text),
          'imageUrl': _imageUrlController.text,
        });
        // Clear text fields after adding the plane
        _registrationController.clear();
        _engineTypeController.clear();
        _totalHoursController.clear();
        _imageUrlController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plane added successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent.withOpacity(0.7),
          content: Text('Failed to add plane: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              onPressed: _addPlane,
              child: const Text('Add Plane'),
            ),
          ],
        ),
      ),
    );
  }
}
