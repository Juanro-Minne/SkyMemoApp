import 'dart:io'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_logbook/components/plane_logging_form.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({Key? key}) : super(key: key);

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  bool _showForm = false;
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _totalHoursController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _addPlane({
  required String registration,
  required String engineType,
  required int totalHours,
  String? imageUrl,
}) async {
  try {
    String? imageURL;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Convert image file path to File object
      File imageFile = File(imageUrl);

      // Upload image to Firebase Storage
      String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('plane_images')
          .child('$imageFileName.jpg');
      await ref.putFile(imageFile);

      // Get image URL
      imageURL = await ref.getDownloadURL();
    }

    // Get the current user's email
    User? user = _auth.currentUser;
    String? userEmail = user?.email;

    if (userEmail != null) {
      // Add plane details to Firestore with the linked user's email
      await _firestore.collection('planes').add({
        'userId': userEmail,
        'registration': registration,
        'engineType': engineType,
        'totalHours': totalHours,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageURL,
        // Add other fields as needed
      });
    }

    // Clear text controllers after adding plane
    _registrationController.clear();
    _engineTypeController.clear();
    _totalHoursController.clear();
    _imageUrlController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plane added successfully')),
    );
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
