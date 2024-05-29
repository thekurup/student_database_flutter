// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:student_db/db_control/student.dart';
import 'package:student_db/screens/home.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  File? _selectedImage;
  final dbHelper = DatabaseHelper();
  final _userNameController = TextEditingController();
  final _userPlaceController = TextEditingController();
  final _userContactController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 126, 126, 126),
            title: Text("Registration",
                style: TextStyle(fontSize: 20, color: Colors.white))),
        body: SingleChildScrollView(
          child: Container(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Add New Student",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 1),
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 2,
                                color: const Color.fromARGB(255, 18, 18, 18)),
                            //borderRadius: BorderRadius.circular(10)
                          ),
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.fill,
                                )
                              : Center(
                                  child: Text(
                                  'Add student photo',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ))),
                    ),
                    Column(children: [
                      IconButton(
                        onPressed: () {
                          _pickImage();
                        },
                        icon: Icon(Icons.photo),
                        tooltip: "select from gallery",
                      ),
                      IconButton(
                          onPressed: () {
                            _photoImage();
                          },
                          icon: Icon(Icons.camera),
                          tooltip: "open camera")
                    ])
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      controller: _userNameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: "Name",
                          hintText: "Enter Name"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your number';
                        }
                        return null;
                      },
                      controller: _userContactController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: "Phone Number",
                          hintText: "Enter Phone Number"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your place';
                        }
                        return null;
                      },
                      controller: _userPlaceController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: "Place",
                          hintText: "Enter Student Place"),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(color: Colors.black),
                              backgroundColor:
                                  const Color.fromARGB(255, 70, 234, 75)),
                          onPressed: () {
                            _insertData(context);
                          },
                          child: Text('Update')),
                      SizedBox(
                        width: 15,
                      ),
                      TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(color: Colors.black),
                              backgroundColor: Color.fromARGB(255, 255, 0, 0)),
                          onPressed: () {
                            _userContactController.text = '';
                            _userNameController.text = '';
                            _userPlaceController.text = '';
                          },
                          child: Text('Clear')),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  //insertion happening here start
  void _insertData(BuildContext context) async {
    final String name = _userNameController.text;
    final int contact = int.tryParse(_userContactController.text) ?? 0;
    final String place = _userPlaceController.text;

    if (name.isNotEmpty && contact > 0 && place.isNotEmpty) {
      final imageFileName =
          'student_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile =
          File('${(await getTemporaryDirectory()).path}/$imageFileName');
      await _selectedImage!.copy(imageFile.path);

      final row = {
        'name': name,
        'place': place,
        'contact': contact,
        'imagePath': imageFile.path,
      };
      // print(row);
      dbHelper.insert(row).then((id) {
        setState(() {
          _userNameController.clear();
          _userPlaceController.clear();
          _userContactController.clear();

          _selectedImage = null;
        });
      });
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Fill All Data, Including an Image'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 2),
      ));
    }
  }

//insertion happening here end
  Future<void> _photoImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
}