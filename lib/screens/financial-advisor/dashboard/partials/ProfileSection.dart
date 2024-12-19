import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wise/providers/userGlobalVariables.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // Load user data when this widget is built
    UserData().retrieveLoginUser(userId);

    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 1)), // Simulate a short delay to ensure data is fetched
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If user data is not found or UID is empty, display an error message
        if (userId.isEmpty) {
          return const Center(child: Text('No user data available'));
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60.0,
                backgroundImage: UserData().imagePath.isNotEmpty
                    ? NetworkImage(UserData().imagePath)
                    : NetworkImage(UserData().defaultImagePath),
                backgroundColor: Colors.amber.shade100,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                UserData().fullName.isNotEmpty
                    ? UserData().fullName
                    : 'No Name Available',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF8E4B2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
