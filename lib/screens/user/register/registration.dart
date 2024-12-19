import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:wise/screens/user/login/login.dart'; // Add this line
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Text controllers to get input from the user
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Initialize user details with default values
  String imagePath = ''; // Default to empty string
  String phoneNumber = ''; // Default to empty string
  String occupation = ''; // Default to empty string
  String city = ''; // Default to empty string
  String postalCode = ''; // Default to empty string
  String state = ''; // Default to empty string
  String street = ''; // Default to empty string
  String unit = ''; // Default to empty string
  bool isBan = false; // Default to false
  int age = 0; // Default to 0

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _confirmPasswordVisible = false;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0b0f12),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Center(
                child: Image.asset(
                  'assets/images/logo/word.png',
                  width: 300,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1a1f24),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Join the cosmic community',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: fullNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle:
                            TextStyle(color: Color(0xFFB1B4B8), fontSize: 14.0),
                        suffixIcon:
                            Icon(Icons.person, color: Color(0xFFB1B4B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 16.0),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle:
                            TextStyle(color: Color(0xFFB1B4B8), fontSize: 14.0),
                        suffixIcon: Icon(Icons.email, color: Color(0xFFB1B4B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 16.0),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle:
                            TextStyle(color: Color(0xFFB1B4B8), fontSize: 14.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color(0xFFB1B4B8),
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 16.0),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle:
                            TextStyle(color: Color(0xFFB1B4B8), fontSize: 14.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color(0xFFB1B4B8),
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 16.0),
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF8E4B2),
                          minimumSize: Size(double.infinity, 50),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                16.0), // Adjust the radius as needed
                          ),
                        ),
                        onPressed: () async {
                          // Registration logic using Firebase Auth
                          String fullName = fullNameController.text.trim();
                          String email = emailController.text.trim();
                          String password = passwordController.text.trim();
                          String confirmPassword =
                              confirmPasswordController.text.trim();

                          if (fullName.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty ||
                              confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please fill out all fields"),
                                backgroundColor: Colors.red,
                                duration: Duration(
                                    seconds:
                                        2), // Duration for which the snackbar is shown
                              ),
                            );
                            print("One or more fields are empty");
                            return;
                          }

                          if (password != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Passwords do not match"),
                                backgroundColor: Colors.red,
                                duration: Duration(
                                    seconds:
                                        2), // Duration for which the snackbar is shown
                              ),
                            );
                            print("Passwords do not match");
                            return;
                          }

                          _showLoadingDialog(); // Show loading indicator

                          try {
                            print("Attempting to register user");
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            // Save user info in Firestore with default values, including address as a nested map
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(userCredential.user!.uid)
                                .set({
                              'name': fullName,
                              'email': email,
                              'createdAt': DateTime.now(),
                              'updatedAt':
                                  DateTime.now(), // Added updatedAt field
                              'imagePath': imagePath,
                              'phoneNumber': phoneNumber,
                              'password': password,
                              'occupation': occupation,
                              'address': {
                                'city': city,
                                'postalCode': postalCode,
                                'state': state,
                                'street': street,
                                'unit': unit,
                              },
                              'isBan': isBan,
                              'age': age,
                            });

                            // Create folders in Firebase Storage for this user
                            final FirebaseStorage storage =
                                FirebaseStorage.instance;
                            final String userFolder =
                                "users/${userCredential.user!.uid}";

                            // Define paths for each folder
                            final String profilePath = "$userFolder/profile/";
                            final String icFrontPath = "$userFolder/icFront/";
                            final String icBackPath = "$userFolder/icBack/";

                            // Upload a zero-byte file to each path to initialize the folders
                            await storage
                                .ref(profilePath)
                                .child(".keep")
                                .putData(Uint8List(0));
                            await storage
                                .ref(icFrontPath)
                                .child(".keep")
                                .putData(Uint8List(0));
                            await storage
                                .ref(icBackPath)
                                .child(".keep")
                                .putData(Uint8List(0));

                            _hideLoadingDialog(); // Hide loading indicator

                            print(
                                "Profile, icFront, and icBack folders created in Firebase Storage.");

                            // Show success dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Color(
                                      0xFF1E1E1E), // Dark background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        16.0), // Rounded corners
                                  ),
                                  title: Text(
                                    "Registration Successful",
                                    style: TextStyle(
                                      color: Color(
                                          0xFFF8E4B2), // Light yellow color for title text
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    "Your account has been created successfully.",
                                    style: TextStyle(
                                      color: Color(
                                          0xFFF8E4B2), // Light yellow color for content text
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Color(
                                            0xFFF8E4B2), // Light yellow background
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Button shape
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 10.0),
                                      ),
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Color(
                                              0xFF1E1E1E), // Dark text color for button
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LoginPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } on FirebaseAuthException catch (e) {
                            String message;
                            switch (e.code) {
                              case 'weak-password':
                                message = 'The password provided is too weak.';
                                break;
                              case 'email-already-in-use':
                                message =
                                    'The account already exists for that email.';
                                break;
                              case 'invalid-email':
                                message = 'The email address is not valid.';
                                break;
                              default:
                                message =
                                    'Registration failed. Please try again.';
                                break;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.red,
                                duration: Duration(
                                    seconds:
                                        2), // Duration for which the snackbar is shown
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                  ], // Column children
                ), // Column
              ), // Container
              SizedBox(height: 25),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account?   ',
                    style: TextStyle(color: Color(0xFF9E9E9E)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Log In',
                        style: TextStyle(color: Color(0xFF4D81E7)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to Login Page
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          },
                      ),
                    ],
                  ),
                ),
              ), // Center
              SizedBox(height: 20), // Added extra space after the container
            ],
          ),
        ),
      ),
    ); // Scaffold
  }
}
