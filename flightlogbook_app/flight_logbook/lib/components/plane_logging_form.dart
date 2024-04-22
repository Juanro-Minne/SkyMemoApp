import 'package:flutter/material.dart';
import 'package:flight_logbook/components/custom_button.dart';
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
  final List<String> _engineTypes = ['Single Prop', 'Twin Prop', 'Turbine'];
  String? _selectedEngineType;

  @override
  void initState() {
    super.initState();
    _registrationController.addListener(() {
      final text = _registrationController.text.toUpperCase();
      _registrationController.value = _registrationController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                CustomTextField(
                  controller: _registrationController,
                  labelText: 'Registration',
                  hintText: 'Registration:ex: ZS-ABC',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter plane Registration:ex: ZS-ABC';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      labelText: 'Select Engine type',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  value: _selectedEngineType,
                  items: _engineTypes.map((String engineType) {
                    return DropdownMenuItem(
                      value: engineType,
                      child: Text(engineType),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEngineType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an engine type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25.0),
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
                const SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor:
                            const Color.fromARGB(255, 245, 228, 178),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _imageFile = File(pickedFile.path);
                          });
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.cloud_upload),
                          SizedBox(width: 30),
                          Text('Upload Image here',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                _imageFile != null
                    ? Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10.0),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  _imageFile!,
                                  width: 270,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _imageFile = null;
                                  });
                                },
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                const Divider(
                  color: Colors.blueGrey,
                  thickness: 1,
                ),
                const SizedBox(height: 15.0, width: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: MyButton(
                    disabled: false,
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        String registration =
                            _registrationController.text.trim().toUpperCase();
                        registration =
                            '${registration.substring(0, 2)}-${registration.substring(2)}';
                        int totalHours =
                            int.parse(_totalHoursController.text.trim());

                        widget.onAddPlane(
                          registration: registration,
                          engineType: _selectedEngineType!,
                          totalHours: totalHours,
                          imageFile: _imageFile,
                        );
                      }
                    },
                    description: "Add Plane",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: MyButton(
                    onTap: () {
                      _engineTypeController.clear();
                      _registrationController.clear();
                      _totalHoursController.clear();
                      setState(() {
                        _imageFile = null;
                      });
                    },
                    description: "Clear",
                    disabled: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
