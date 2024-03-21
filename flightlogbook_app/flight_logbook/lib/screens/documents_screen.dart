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
  PlatformFile? _selectedFile;

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
      if (fileBytes != null) { 
        final reference = FirebaseStorage.instance.ref('documents/$fileName');
        final uploadTask = reference.putData(fileBytes);
        final TaskSnapshot uploadSnapshot = await uploadTask;
        final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

        User? user = _auth.currentUser;
        if (user != null) {
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File bytes are null'),
            backgroundColor: Color.fromARGB(255, 231, 85, 85),
            duration: Duration(seconds: 3),
          ),
        );
      }
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
            Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Expiry Date: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
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
            MyButton(
                onTap: () {
                  setState(() {
                    _selectedFile = null;
                  });
                },
                description: 'Clear File'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
