// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use, avoid_function_literals_in_foreach_calls
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/custom_button.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<int> _selectedFileBytes = [];
  List<String> _documentNames = [];
  bool _isloading = true;

  late DateTime _expiryDate = DateTime.now();
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _fetchUserDocuments();
  }

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
        final file = File(_selectedFile!.path!);
        List<int> bytes = await file.readAsBytes();
        _updateSelectedFileBytes(bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  void _updateSelectedFileBytes(List<int> bytes) {
    setState(() {
      _selectedFileBytes = bytes;
    });
  }

  Future<void> _uploadDocument() async {
    try {
      if (_selectedFileBytes.isNotEmpty) {
        final fileName = _selectedFile!.name;
        final fileBytes = Uint8List.fromList(_selectedFileBytes);

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
            'userId': user.email,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully'),
              backgroundColor: Color.fromARGB(255, 105, 123, 240),
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {
            _selectedFile = null;
            _selectedFileBytes = [];
          });
          _fetchUserDocuments();
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e')),
      );
    }
  }

  Future<void> _fetchUserDocuments() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot userDocsSnapshot = await _firestore
            .collection('documents')
            .where('userId', isEqualTo: user.email)
            .get();
        setState(() {
          _documentNames = userDocsSnapshot.docs
              .map<String>((doc) => doc['fileName'] as String)
              .toList();
          _isloading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching documents: $e')),
      );
    }
  }

  Future<void> _downloadFile(String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref('documents/$fileName');
      final String downloadUrl = await storageRef.getDownloadURL();
      final Uri url = Uri.parse(downloadUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch download URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  Future<void> _deleteFile(String fileName) async {
    try {
      final reference = FirebaseStorage.instance.ref('documents/$fileName');
      await reference.delete();

      await _firestore
          .collection('documents')
          .where('fileName', isEqualTo: fileName)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
      });
      setState(() {
        _documentNames.remove(fileName);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document deleted successfully'),
          backgroundColor: Color.fromARGB(255, 105, 123, 240),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox.shrink(),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Please select an expiry date',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 49, 67, 76),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MyButton(
              onTap: _selectFile,
              description: 'Select File',
            ),
            _selectedFile != null
                ? const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'File selected',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 49, 67, 76),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(height: 10),
            const Center(
              child: Text(
                'Please select a expiry date',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 49, 67, 76),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MyButton(
              onTap: () => _selectExpiryDate(context),
              description: 'Select Expiry Date',
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Expiry Date: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 49, 67, 76),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            MyButton(
              onTap: _uploadDocument,
              description: 'Upload Document',
            ),
            const SizedBox(height: 10),
            const Divider(
              color: Colors.blueGrey,
              thickness: 2,
            ),
            const SizedBox(height: 5),
            const Text(
              'User Documents:',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 49, 67, 76),
                fontWeight: FontWeight.bold,
              ),
            ),
            _isloading
                ? const SpinKitHourGlass(
                    color: Color.fromARGB(255, 255, 196, 85))
                : const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _documentNames.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(_documentNames[index]),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.file_download,
                        color: Colors.brown,
                      ),
                      onPressed: () {
                        _downloadFile(_documentNames[index]);
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _deleteFile(_documentNames[index]);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
