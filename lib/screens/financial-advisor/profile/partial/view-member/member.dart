import 'package:flutter/material.dart';

class MemberDetailPage extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String email;
  final String age; // Age as a string
  final String imagePath;
  final String occupation;

  const MemberDetailPage({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.age, // Include age as a string
    required this.imagePath,
    required this.occupation, required String userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        elevation: 0,
        title: Text(
          name,
          style: const TextStyle(
            color: Color(0xFFF8E4B2),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User Image with a shadow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10.0,
                        spreadRadius: 5.0,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 80.0,
                    backgroundImage: imagePath.isNotEmpty
                        ? NetworkImage(imagePath)
                        : null,
                    backgroundColor: Colors.white,
                    child: imagePath.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 80.0,
                            color: Colors.black,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 30.0),
                // User details container
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Full Name:', name),
                      const SizedBox(height: 12.0),
                      _buildDetailRow('Age:', age),
                      const SizedBox(height: 12.0),
                      _buildDetailRow('Occupation:', occupation),
                      const SizedBox(height: 12.0),
                      _buildDetailRow('Phone:', phoneNumber),
                      const SizedBox(height: 12.0),
                      _buildDetailRow('Email:', email),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create detail rows with uniform styling
  Widget _buildDetailRow(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title ',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8E4B2),
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
