import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messaing/components/my_back_button.dart';
import 'dart:io';
class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  int? _age;
  String? _gender;
  String? _officialEmail;
  String? _teamDesignation;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isUploading = false;
  bool _isEditing = false;

  Future<void> pickImage() async {
    if (FirebaseAuth.instance.currentUser == null) {
      print('User is not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to upload a profile picture')),
      );
      return;
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isUploading = true;
      });
      await uploadImage();
    }
  }
  Future<void> uploadImage() async {
    if (_image == null || currentUser == null) {
      print('Image or user is null');
      return;
    }

    try {
      print('Starting upload process...');
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(currentUser!.uid)
          .child('profile.jpg');

      print('Uploading file...');
      await ref.putFile(_image!);
      print('File uploaded successfully');

      print('Getting download URL...');
      final url = await ref.getDownloadURL();
      print('Download URL obtained: $url');

      print('Updating Firestore...');
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .update({'profile_picture': url});
      print('Firestore updated successfully');

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.uid)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.uid)
          .set({
        'email': currentUser!.email,
        'username': currentUser!.displayName ?? 'User',
        'profile_picture': null,
        'age': null,
        'gender': null,
        'official_email': null,
        'team_designation': null,
      });

      doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.uid)
          .get();
    }

    return doc;
  }

  Widget _buildProfileInfo(Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoTile(Icons.cake, 'Age', user['age']?.toString() ?? 'Not set'),
        _buildInfoTile(Icons.person, 'Gender', user['gender'] ?? 'Not set'),
        _buildInfoTile(Icons.email, 'Official Email', user['official_email'] ?? 'Not set'),
        _buildInfoTile(Icons.work, 'Team Designation', user['team_designation'] ?? 'Not set'),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Age',
              prefixIcon: Icon(Icons.cake),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              return null;
            },
            onSaved: (value) => _age = int.tryParse(value ?? ''),
          ),
          const SizedBox(height: 16),
          Text('Gender:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: 'Male',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value as String?;
                  });
                },
              ),
              Text('Male'),
              Radio(
                value: 'Female',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value as String?;
                  });
                },
              ),
              Text('Female'),
              Radio(
                value: 'Others',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value as String?;
                  });
                },
              ),
              Text('Others'),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Official Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your official email';
              }
              return null;
            },
            onSaved: (value) => _officialEmail = value,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Team Designation',
              prefixIcon: Icon(Icons.work),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your team designation';
              }
              return null;
            },
            onSaved: (value) => _teamDesignation = value,
          ),
          const SizedBox(height: 24),
          ElevatedButton(


            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUser!.uid)
                    .update({
                  'age': _age,
                  'gender': _gender,
                  'official_email': _officialEmail,
                  'team_designation': _teamDesignation,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated successfully')),
                );
                setState(() {
                  _isEditing = false;
                });
              }
            },

            child: Text('Save',),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Profile'),
        leading: MyBackButton(),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: currentUser == null
          ? Center(child: Text("User not logged in"))
          : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            Map<String, dynamic> user = snapshot.data!.data()!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    /*
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor],
                      ),
                    ),*/
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _isUploading ? null : pickImage,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundImage: user['profile_picture'] != null
                                      ? NetworkImage(user['profile_picture'])
                                      : null,
                                  child: user['profile_picture'] == null
                                      ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                      : null,
                                ),
                              ),
                            ),
                            if (_isUploading) CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text(
                              user['username'] ?? '',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                        /*
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user['email'] ?? '',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isEditing ? _buildEditForm() : _buildProfileInfo(user),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("No Data"));
          }
        },
      ),
    );
  }
}