// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_logbook/components/plane_logging_form.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({Key? key}) : super(key: key);

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  bool _showForm = false;
  bool _isNavBarVisible = true;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showForm = !_showForm;
                    });
                  },
                  child: Text(_showForm ? 'Hide Form' : 'Add New Plane'),
                ),
              ),
              if (_showForm)
                PlaneLoggingForm(
                  onAddPlane: _addPlane,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
