import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_db/db_control/student.dart';
import 'package:student_db/screens/details.dart';
import 'package:student_db/screens/reg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  final dbhelper = DatabaseHelper();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPlaceController = TextEditingController();
  final TextEditingController _userContactController = TextEditingController();

  File? _selectedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          centerTitle: true,
          title: Text("Students Updates"),
          leading: Icon(Icons.home),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.refresh))
          ],
        ),
        // body: Center(
        //   child: Text("sdadas"),
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Register()));
          },
          child: Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40)),
                    prefixIcon: Icon(Icons.search),
                    hintText: 'search name ',
                    //label: Text("search")
                  ),
                  onChanged: (valu) {
                    setState(() {});
                  },
                ),
              ),
            ),
            // Add some spacing between the TextField and the list
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbhelper.searchAll(searchController.text),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    // return CircularProgressIndicator();
                  }
                  final data = snapshot.data!;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          showtData(data[index], context);
                        },
                        leading: CircleAvatar(
                            backgroundImage:
                                FileImage(File(data[index]['imagePath']))),
                        title: Text(data[index]['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                //  edit Function Called
                                _editData(data[index], context);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            SizedBox(width: 15),
                            IconButton(
                              onPressed: () {
                                //  delete Function Callled
                                _showDeleteDialog(data[index]['id'], context);
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ));
  }

  void _showDeleteDialog(int id, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Data'),
          content: Text('Are you sure you want to delete this data?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteData(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteData(int id) {
    dbhelper.delete(id).then((rowsDeleted) {
      if (rowsDeleted > 0) {
        setState(() {
          // Reload data after deletion
        });
      }
    });
  }

  void _editData(Map<String, dynamic> data, BuildContext context) {
    _userNameController.text = data['name'];
    _userContactController.text = data['contact'].toString();
    _userPlaceController.text = data['place'];
    _selectedImage = File(data['imagePath']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _userContactController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Age'),
                ),
                TextField(
                  controller: _userPlaceController,
                  decoration: InputDecoration(labelText: 'Place'),
                ),
                Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border:
                              Border.all(width: 2, color: Colors.deepOrange),
                        ),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover)),
                  ),
                  Column(children: [
                    IconButton(
                        onPressed: () {
                          _pickImage();
                        },
                        icon: Icon(Icons.photo)),
                    IconButton(
                        onPressed: () {
                          _photoImage();
                        },
                        icon: Icon(Icons.camera))
                  ])
                ]),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                updateData(data['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateData(int id) {
    final name = _userNameController.text;
    final contact = int.tryParse(_userContactController.text) ?? 0;
    final place = _userPlaceController.text;
    final imagePath = _selectedImage!.path;

    if (name.isNotEmpty && contact > 0 && place.isNotEmpty) {
      final row = {
        'id': id,
        'name': name,
        'contact': contact,
        'place': place,
        'imagePath': imagePath
      };
      dbhelper.update(row).then((rowsUpdated) {
        if (rowsUpdated > 0) {
          setState(() {
            _userNameController.clear();
            _userContactController.clear();
            _userPlaceController.clear();
          });
        }
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

  Future<void> _photoImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void showtData(Map<String, dynamic> data, BuildContext context) {
    var name = data['name'];
    var contact = data['contact'];
    var place = data['place'];
    var imagePath = data['imagePath'];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          name: name,
          place: place,
          contact: contact,
          imagePath: imagePath,
        ),
      ),
    );
  }
}