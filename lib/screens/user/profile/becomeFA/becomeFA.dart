import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BecomeFinancialAdvisorPage extends StatefulWidget {
  @override
  _BecomeFinancialAdvisorPageState createState() =>
      _BecomeFinancialAdvisorPageState();
}

class _BecomeFinancialAdvisorPageState
    extends State<BecomeFinancialAdvisorPage> {
  File? _frontImage;
  File? _backImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _backImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    // Validation: Check if both images are provided
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please upload both front and back images."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user ID
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "defaultUser";

      // Upload images to Firebase Storage
      String frontImageUrl =
          await _uploadImage(_frontImage!, userId, 'icFront');
      String backImageUrl = await _uploadImage(_backImage!, userId, 'icBack');

      // Create a reference to the user document in the Users collection
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Save the data in Firestore under 'FinancialAdvisors' collection with an auto-generated ID
      DocumentReference advisorDocRef =
          await FirebaseFirestore.instance.collection('FinancialAdvisors').add({
        'icImageFront': frontImageUrl,
        'icImageBack': backImageUrl,
        'isVerified': false, // Set to false initially until verified
        'rejectReason': "",
        'userID': userRef, // Insert as a reference instead of a string
      });

      print("Document created with ID: ${advisorDocRef.id}");

      setState(() {
        _isLoading = false;
      });

      // Navigate back and pass a success message
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request submitted successfully!"),
          backgroundColor: Colors.blueAccent,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit request. Please try again.")),
      );
    }
  }

  Future<String> _uploadImage(
      File imageFile, String userId, String folder) async {
    // Define storage path and reference
    final storageRef = FirebaseStorage.instance.ref().child(
        'users/$userId/$folder/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => {});

    // Get and return the download URL
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            SizedBox(height: 15), // Add 20px space above the AppBar
            AppBar(
              title: Text(
                'Become Financial Advisor',
                style: TextStyle(
                  color: Color(0xFFF8E4B2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.white, // Set back icon color to white
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildUploadSection(), // Show upload section
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Submitting your request...",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to show the upload section
  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.white70, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Please upload the front and back images of your identification card for verification.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        // Front ID Card Upload
        _buildUploadCard(
          title: "Identification Front",
          image: _frontImage,
          onTap: () => _pickImage(true),
        ),
        SizedBox(height: 20),
        // Back ID Card Upload
        _buildUploadCard(
          title: "Identification Back",
          image: _backImage,
          onTap: () => _pickImage(false),
        ),
        SizedBox(height: 30),
        // Submit Button
        ElevatedButton(
          onPressed: _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // Bright yellow-gold color
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "Submit Request",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard(
      {required String title, File? image, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: image == null
                  ? Icon(Icons.add_a_photo, size: 50, color: Colors.white70)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(image, fit: BoxFit.cover),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
