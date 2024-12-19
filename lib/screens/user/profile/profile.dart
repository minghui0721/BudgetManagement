import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/screens/financial-advisor/FinancialAdvisor.dart';
import 'package:wise/screens/user/login/login.dart';
import 'package:wise/screens/user/profile/becomeFA/becomeFA.dart';
import 'package:wise/screens/user/profile/categories.dart';
import 'package:wise/screens/user/profile/editProfile.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/user/profile/financialAdvice/approvedFinancialAdvice.dart';
import 'package:wise/screens/user/profile/financialAdvice/financialAdvice.dart';
import 'package:wise/screens/user/profile/becomeFA/pendingFA.dart';
import 'package:wise/screens/user/profile/financialAdvice/pendingFinancialAdvice.dart';
import 'package:wise/screens/user/profile/financialAdvice/rejectFinancialAdvice.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _refreshProfileImage() {
    setState(() {
      // This triggers a rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.0), // Add margin space above the AppBar
            AppBar(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              title: Text(
                'User Profile',
                style: TextStyle(
                  color: Color(0xFFF8E4B2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('FinancialAdvisors')
                      .where('userID',
                          isEqualTo: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userId))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    // Check if the query returned any documents and if the 'isVerified' field is true
                    bool isVerified = snapshot.hasData &&
                        snapshot.data!.docs.isNotEmpty &&
                        snapshot.data!.docs.first.get('isVerified') == true;

                    return Column(
                      children: [
                        // Profile Details
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    UserData().fullName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    UserData().phoneNumber.isEmpty
                                        ? 'Phone number not set'
                                        : UserData().phoneNumber,
                                    style: TextStyle(
                                      color: Color(0xFFF8E4B2),
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SizedBox(height: 2.0),
                                  Text(
                                    UserData().email,
                                    style: TextStyle(
                                      color: Color(0xFFF8E4B2),
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              // Profile Image
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: UserData().imagePath.isNotEmpty
                                    ? NetworkImage(UserData().imagePath)
                                    : NetworkImage(UserData().defaultImagePath),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.0),
                        // Options List
                        _buildOptionItem(context, Icons.person, 'Edit Profile',
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                onImageUpdated:
                                    _refreshProfileImage, // Pass the callback
                              ),
                            ),
                          );
                        }),
                        _buildOptionItem(context, Icons.category, 'Categories',
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoriesPage()),
                          );
                        }),
                        // Call _navigateToAdvisorPage inside _buildOptionItem
                        _buildOptionItem(
                          context,
                          Icons.request_page,
                          'Financial Advice',
                          () => _navigateToAdvisorPage(context),
                        ),
                        // Conditionally show either "Switch to Financial Advisor Account" or "Become Financial Advisor"
                        isVerified
                            ? _buildOptionItem(
                                context,
                                Icons.swap_horiz,
                                'Switch to Financial Advisor Account',
                                _switchToFAAccount,
                              )
                            : _buildOptionItem(
                                context,
                                Icons.emoji_people,
                                'Become Financial Advisor',
                                () async {
                                  bool isPending =
                                      await _checkIfRequestPending();

                                  if (isPending) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PendingRequestPage()),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BecomeFinancialAdvisorPage()),
                                    );
                                  }
                                },
                              ),
                        _buildOptionItem(context, Icons.logout, 'Logout', () {
                          _confirmLogout(context);
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.0),
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(width: 20.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToAdvisorPage(BuildContext context) async {
    final provider =
        Provider.of<FinancialAdvisorProvider>(context, listen: false);
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    // Fetch advisor ID based on the user ID
    await provider.fetchAdvisorIdByUserId(userId);

    // Get the advisor ID from the provider
    String? advisorId = provider.advisorId;

    print(advisorId);

    // Check if there is a pending request
    if (advisorId != null) {
      RequestStatus status =
          await provider.checkRequestStatus(advisorId, userId);

      // Navigate based on request status
      if (status == RequestStatus.pending) {
        _navigateToPendingPage(context, provider.advisorName!);
      } else if (status == RequestStatus.approved) {
        _navigateToApprovedPage(
          context,
          provider.advisorName!,
          provider.advisorImagePath!,
          advisorId,
          provider.occupation!,
          provider.email!,
          provider.phoneNumber!,
          provider.age,
        );
      } else if (status == RequestStatus.rejected) {
        String rejectionReason =
            await provider.getRejectionReason(advisorId, userId);
        _navigateToRejectedPage(context, rejectionReason);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No advisor found for this user."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinancialAdvisorSelectionPage(),
        ),
      );
    }
  }

  void _navigateToPendingPage(BuildContext context, String advisorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PendingPage(advisorName: advisorName),
      ),
    );
  }

  void _navigateToApprovedPage(
    BuildContext context,
    String advisorName,
    String advisorImagePath,
    String faId,
    String occupation, // New parameter for occupation
    String email, // New parameter for email
    String phoneNumber, // New parameter for phone number
    int? age,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApprovedPage(
          advisorName: advisorName,
          advisorImage: advisorImagePath, // Pass the advisor's image URL
          faId: faId,
          occupation: occupation, // Pass occupation
          email: email, // Pass email
          phoneNumber: phoneNumber, // Pass phone number
          age: age,
        ),
      ),
    );
  }

  void _navigateToRejectedPage(BuildContext context, String rejectionReason) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RejectedPage(rejectionReason: rejectionReason),
      ),
    );
  }

  Future<bool> _checkIfRequestPending() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "defaultUser";

    try {
      // Create a reference to the Users collection document for the current user
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Query the 'FinancialAdvisors' collection for documents with userID matching the userRef
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .where('userID', isEqualTo: userRef)
          .limit(
              1) // Limit to 1 result as each user should only have one document
          .get();

      // Check if a matching document exists and if 'isVerified' is false
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('isVerified') == false;
      }
    } catch (e) {
      print("Error checking request status: $e");
    }

    return false;
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2C2C2C),
          title: Text(
            "Confirm Logout",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _logoutUser(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _logoutUser(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Functionality to switch to Financial Advisor account with confirmation
  void _switchToFAAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2C2C2C),
          title: Text(
            "Confirm Switch",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Are you sure you want to switch to the Financial Advisor account?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Switch", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FinancialAdvisorScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
