import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:wise/helper/FetchDataHelper.dart';
import 'package:wise/models/Admin.dart';
import 'package:wise/repositories/AdminRepository.dart';
import 'package:wise/screens/admin/AdminMain.dart';
import 'package:wise/screens/user/register/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/user/rootPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AdminRepository _adminRepository = AdminRepository();

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _signInWithGoogle() async {
    try {
      print("Starting Google sign-in...");

      _showLoadingDialog();
      print("Loading dialog displayed.");

      // Sign out of any previously authenticated Google account
      await GoogleSignIn().signOut();

      // Attempt Google sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print("Google user: ${googleUser?.displayName}, ${googleUser?.email}");

      if (googleUser == null) {
        // User canceled the Google sign-in process
        _hideLoadingDialog();
        print("Google sign-in was canceled by the user.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google sign-in canceled")),
        );
        return;
      }

      // Retrieve Google authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print("Google Access Token: ${googleAuth.accessToken}");
      print("Google ID Token: ${googleAuth.idToken}");

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _hideLoadingDialog();
        print("Google authentication tokens are missing.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to retrieve authentication tokens.")),
        );
        return;
      }

      // Create OAuthCredential with Google tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("OAuthCredential created: $credential");

      // Sign in with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      print("Firebase sign-in successful. User UID: ${user?.uid}");

      if (user != null) {
        // Check if user document exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // User document does not exist, create a new document with default values
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'createdAt': DateTime.now(),
            'updatedAt': DateTime.now(),
            'imagePath': user.photoURL ?? '',
            'phoneNumber': '', // Default to empty string
            'password': '', // Set to empty string for Google sign-in
            'occupation': '', // Default to empty string
            'address': {
              'city': '',
              'postalCode': '',
              'state': '',
              'street': '',
              'unit': '',
            },
            'isBan': false, // Default to false
            'age': 0, // Default to 0
          });
          print("User data stored in Firestore for new user.");
        } else {
          print("User document already exists in Firestore.");
        }

        // Retrieve login user data and fetch additional data
        UserData().retrieveLoginUser(user.uid);
        await FetchDataHelper.fetchData(context);
      }

      _hideLoadingDialog();
      print("Navigation to RootPage initiated.");

      // Navigate to the RootPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RootPage(currentIndex: 0)),
      );
    } catch (e) {
      _hideLoadingDialog();
      print("Error during Google sign-in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google sign-in failed. Please try again.")),
      );
    }
  }

  // Forgot password functionality
  Future<void> _forgotPassword() async {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController resetEmailController =
            TextEditingController();
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            "Forgot Password",
            style: TextStyle(color: Color(0xFFF8E4B2)),
          ),
          content: TextField(
            controller: resetEmailController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter your email",
              labelStyle: TextStyle(color: Color(0xFFF8E4B2)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF8E4B2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4D81E7)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String email = resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset email sent."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to send reset email."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                "Reset Password",
                style: TextStyle(color: Color(0xFFF8E4B2)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Color(0xFFF8E4B2)),
              ),
            ),
          ],
        );
      },
    );
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
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Color(0xFFB1B4B8)),
                        suffixIcon: Icon(Icons.email, color: Color(0xFFB1B4B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D81E7)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Color(0xFFB1B4B8)),
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
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF4D81E7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF8E4B2),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onPressed: () async {
                          String email = emailController.text.trim();
                          String password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please fill out all fields."),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          _showLoadingDialog();

                          try {
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            String uid = userCredential.user!.uid;

                            Admin? admin =
                                await _adminRepository.isAdmin(email);

                            _hideLoadingDialog();

                            UserData().retrieveLoginUser(uid);
                            await FetchDataHelper.fetchData(context);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RootPage(currentIndex: 0),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            String message;
                            switch (e.code) {
                              case 'user-not-found':
                                message = 'No user found for that email.';
                                break;
                              case 'wrong-password':
                                message = 'Wrong password provided.';
                                break;
                              default:
                                message = 'Login failed. Please try again.';
                                break;
                            }

                            _hideLoadingDialog();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(message),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2)),
                            );
                          }
                        },
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Divider(color: Colors.grey, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child:
                              Text("OR", style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(
                            child: Divider(color: Colors.grey, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.email),
                        label: Text("Continue with Google"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onPressed: _signInWithGoogle,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Don\'t have an account?   ',
                    style: TextStyle(color: Color(0xFF9E9E9E)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Register',
                        style: TextStyle(color: Color(0xFF4D81E7)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
