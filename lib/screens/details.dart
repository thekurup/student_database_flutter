import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'dart:io';

class DetailsPage extends StatefulWidget {
  final String name;
  final int contact;
  final String place;
  final String? imagePath;

  const DetailsPage({
    super.key,
    required this.name,
    required this.contact,
    required this.place,
    this.imagePath,
  });
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        
        
      ),
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircleAvatar(
              radius: 90,
              backgroundImage: widget.imagePath != null
                  ? FileImage(File(widget.imagePath!))
                  : null,
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("name : ${widget.name}",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
          ),
          ListTile(
            leading: Icon(Icons.arrow_circle_right),
            title: Text("Place : ${widget.place}",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Contact : ${widget.contact}",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
          )
        ],
      ),
      
      
    );
  }
}