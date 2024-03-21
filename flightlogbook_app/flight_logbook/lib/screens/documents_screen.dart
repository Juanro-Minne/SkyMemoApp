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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late DateTime _expiryDate = DateTime.now();
  late PlatformFile? _selectedFile = null;

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

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      } else {
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _uploadDocument() async {
    try {
      if (_selectedFile != null) {
        final file = _selectedFile!;
        final fileName = file.name;
        final fileBytes = file.bytes;
        final reference = FirebaseStorage.instance.ref('documents/$fileName');
        final uploadTask = reference.putData(fileBytes!);
        await uploadTask.whenComplete(() async {
          User? user = _auth.currentUser;
          if (user != null) {
            String downloadUrl = await reference.getDownloadURL();
            await _firestore.collection('documents').add({
              'fileName': fileName,
              'fileUrl': downloadUrl,
              'expiryDate': Timestamp.fromDate(_expiryDate),
              'userId': user.uid,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document uploaded successfully'),
                backgroundColor: Color.fromARGB(255, 105, 123, 240),
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User is not logged in'),
                backgroundColor: Color.fromARGB(255, 231, 85, 85),
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a file to upload'),
            backgroundColor: Color.fromARGB(255, 231, 85, 85),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e')),
      );
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
              onTap: _selectFile,
              description: 'Select File',
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: () => _selectExpiryDate(context),
              description: 'Select Expiry Date',
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: _uploadDocument,
              description: 'Upload Document',
            ),
            const SizedBox(height: 20),
            if (_selectedFile != null)
              Text(
                'Selected File: ${_selectedFile!.name}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Expiry Date: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
