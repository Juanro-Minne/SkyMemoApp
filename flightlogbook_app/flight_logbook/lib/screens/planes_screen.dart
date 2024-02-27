import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_logbook/components/plane_logging_form.dart';
import '../components/tab.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({Key? key}) : super(key: key);

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showForm = false;
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _totalHoursController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TabBar(
                      unselectedLabelColor: Colors.black,
                      labelColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 5,
                      indicator: BoxDecoration(
                        color: const Color.fromARGB(255, 219, 219,
                            219), // Set color for the pill indicator
                        borderRadius: BorderRadius.circular(5),
                      ),
                      controller: _tabController,
                      tabs: const [
                        TabCustom(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          text: 'Log Flights',
                        ),
                        TabCustom(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          text: 'View Flights',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlaneLoggingForm(),
                _buildPlaneList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaneLoggingForm() {
    return PlaneLoggingForm(
      onAddPlane: _addPlane,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPlanes() async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('planes')
            .where('userId', isEqualTo: userEmail)
            .get();
        final planes = querySnapshot.docs.map((doc) => doc.data()).toList();
        return planes;
      } else {
        throw Exception('User email was not found');
      }
    } catch (error) {
      rethrow;
    }
  }

  void _addPlane({
    required String registration,
    required String engineType,
    required int totalHours,
    File? imageFile,
  }) async {
    try {
      String? imageURL;
      if (imageFile != null) {
        String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('plane_images')
            .child('$imageFileName.jpg');
        await ref.putFile(imageFile);
        imageURL = await ref.getDownloadURL();
      }

      User? user = _auth.currentUser;
      String? userEmail = user?.email;

      if (userEmail != null) {
        await _firestore.collection('planes').add({
          'userId': userEmail,
          'registration': registration,
          'engineType': engineType,
          'totalHours': totalHours,
          if (imageURL != null) 'imageUrl': imageURL,
        });
      }
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

  Widget _buildPlaneList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPlanes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final planes = snapshot.data!;
            return ListView.builder(
              itemCount: planes.length,
              itemBuilder: (context, index) {
                final plane = planes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 243, 202, 128),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    title: Text(plane['registration']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plane Registration: ${plane['registration']}'),
                        Text('Engine Type: ${plane['engineType']}'),
                        Text('Total Hours: ${plane['totalHours']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
