import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final VoidCallback onImageUpdated; // Add a callback

  EditProfilePage({required this.onImageUpdated}); // Accept the callback

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String _newImagePath = UserData().imagePath;
  File? _selectedImageFile;

  final TextEditingController nameController =
      TextEditingController(text: UserData().fullName);
  final TextEditingController emailController =
      TextEditingController(text: UserData().email);
  final TextEditingController cityController =
      TextEditingController(text: UserData().city);
  final TextEditingController postalCodeController =
      TextEditingController(text: UserData().postalCode);
  final TextEditingController stateController =
      TextEditingController(text: UserData().state);
  final TextEditingController streetController =
      TextEditingController(text: UserData().street);
  final TextEditingController unitController =
      TextEditingController(text: UserData().unit);
  final TextEditingController ageController = TextEditingController(
      text: UserData().age.toString() == '0' ? '' : UserData().age.toString());
  final TextEditingController occupationController =
      TextEditingController(text: UserData().occupation);
  final TextEditingController phoneNumberController =
      TextEditingController(text: UserData().phoneNumber);

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
        _newImagePath = image.path;
      });
    }
  }

  Future<void> _saveChanges() async {
    String uid = UserData().uid;
    String fullName = nameController.text;
    String email = emailController.text;
    String city = cityController.text;
    String postalCode = postalCodeController.text;
    String state = stateController.text;
    String street = streetController.text;
    String unit = unitController.text;
    int age = ageController.text.isEmpty ? 0 : int.parse(ageController.text);
    String occupation = occupationController.text;
    String phoneNumber = phoneNumberController.text;

    Map<String, dynamic> updatedData = {
      'fullName': fullName,
      'email': email,
      'address': {
        'city': city,
        'postalCode': postalCode,
        'state': state,
        'street': street,
        'unit': unit,
      },
      'age': age,
      'occupation': occupation,
      'phoneNumber': phoneNumber,
    };

    try {
      // If a new image is selected, upload it to the specified folder path
      if (_selectedImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users/$uid/profile/profile.jpg');
        await storageRef.putFile(_selectedImageFile!);
        final imageUrl = await storageRef.getDownloadURL();
        updatedData['imagePath'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update(updatedData);

      UserData().retrieveLoginUser(uid);

      // Call the callback to refresh the image in ProfilePage
      widget.onImageUpdated();

      print("image: ${UserData().imagePath}");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Your profile has been updated successfully."),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      resizeToAvoidBottomInset: true,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.0),
              AppBar(
                backgroundColor: Color(0xFF1E1E1E),
                elevation: 0,
                title: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Color(0xFFF8E4B2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: _selectedImageFile != null
                            ? FileImage(_selectedImageFile!)
                            : UserData().imagePath.isNotEmpty
                                ? NetworkImage(UserData().imagePath)
                                : NetworkImage(UserData().defaultImagePath),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(
                        "Edit picture",
                        style:
                            TextStyle(color: Color(0xFF4D81E7), fontSize: 16.0),
                      ),
                    ),
                    Divider(color: Color(0xFF4D81E7)),
                    SizedBox(height: 20.0),
                    _buildSectionTitle('Personal Information'),
                    _buildTextField(nameController, 'Name'),
                    _buildTextField(emailController, 'Email address'),
                    SizedBox(height: 20.0),
                    _buildSectionTitle('Address'),
                    _buildAddressFields(),
                    SizedBox(height: 20.0),
                    _buildSectionTitle('Additional Information'),
                    _buildTextField(ageController, 'Age'),
                    _buildTextField(occupationController, 'Occupation'),
                    _buildTextField(phoneNumberController, 'Phone Number'),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D81E7),
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Changes"),
                              content: Text(
                                  "Are you sure you want to save the changes?"),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Confirm"),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _saveChanges();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
            color: Color(0xFFF8E4B2),
            fontSize: 18.0,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4D81E7)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildAddressFields() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildTextField(unitController, 'Unit')),
            SizedBox(width: 10.0),
            Expanded(
                child: _buildTextField(postalCodeController, 'Postal Code')),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildTextField(cityController, 'City')),
            SizedBox(width: 10.0),
            Expanded(child: _buildTextField(stateController, 'State')),
          ],
        ),
        SizedBox(height: 10.0),
        _buildTextField(streetController, 'Street'),
      ],
    );
  }
}
