import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/custom_button.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late DateTime _expiryDate = DateTime.now();

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _expiryDate) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  Future<void> _uploadFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = result.files.first;
        final fileName = file.name;
        final fileBytes = file.bytes;
        final reference = FirebaseStorage.instance.ref('$type/$fileName');
        final uploadTask = reference.putData(fileBytes!);
        await uploadTask.whenComplete(() async {
          User? user = _auth.currentUser;
          if (user != null) {
            String downloadUrl = await reference.getDownloadURL();
            await _firestore.collection('users').doc(user.uid).collection('documents').add({
              'fileName': fileName,
              'fileUrl': downloadUrl,
              'expiryDate': Timestamp.fromDate(_expiryDate),
              'documentType': type,
            });
          } else {
            print('User is not logged in');
          }
          print('File uploaded');
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            MyButton(
              onTap: () => _uploadFile('pilot_license'),
              description: 'Upload Pilot License',
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: () => _uploadFile('medical_document'),
              description: 'Upload Medical Document',
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: () => _uploadFile('ppc_check'),
              description: 'Upload PPC Check Document',
            ),
            const SizedBox(height: 20),
            Text(
              'Expiry Date: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
            MyButton(
              onTap: () => _selectExpiryDate(context),
              description: 'Select Expiry Date',
            ),
          ],
        ),
      ),
    );
  }
}
