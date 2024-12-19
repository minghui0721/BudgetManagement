import 'package:flutter/material.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/user/profile/financialAdvice/chat.dart';

class ApprovedPage extends StatelessWidget {
  final String advisorName;
  final String advisorImage;
  final String faId;
  final String? occupation; // Change to nullable
  final String? email; // Change to nullable
  final String? phoneNumber; // Change to nullable
  final int? age; // Add the age parameter

  ApprovedPage({
    required this.advisorName,
    required this.advisorImage,
    required this.faId,
    this.occupation, // Accept occupation as an optional parameter
    this.email, // Accept email as an optional parameter
    this.phoneNumber, // Accept phone as an optional parameter
    this.age, // Accept age as an optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E), // Set the entire background color
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E), // Card background color
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Shadow color
                offset: Offset(0, 4), // Shadow offset
                blurRadius: 8.0, // Blur radius
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 15), // Add space above the AppBar
              AppBar(
                backgroundColor: Color(0xFF1E1E1E),
                title: Text(
                  "Financial Advisor",
                  style: TextStyle(
                    color: Color(0xFFF8E4B2), // Title color
                    fontWeight: FontWeight.bold, // Make the title bold
                    fontSize: 20, // Increased font size for better visibility
                  ),
                ),
                centerTitle: true,
                iconTheme: IconThemeData(
                    color: Colors.white), // Set back icon color to white
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildProfileHeader(),
                    SizedBox(height: 25),
                    _buildInfoCard(
                        "Occupation",
                        (occupation?.isNotEmpty == true)
                            ? occupation!
                            : "-"), // Display hyphen if null or empty
                    _buildInfoCard(
                        "Email",
                        (email?.isNotEmpty == true)
                            ? email!
                            : "-"), // Display hyphen if null or empty
                    _buildInfoCard(
                        "Phone",
                        (phoneNumber?.isNotEmpty == true)
                            ? phoneNumber!
                            : "-"), // Display hyphen if null or empty
                    _buildInfoCard(
                        "Age",
                        (age != null)
                            ? age.toString()
                            : "-"), // Display hyphen if null
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TextChatPage(
                userId: UserData().uid,
                faId: faId,
                advisorName: advisorName,
                isFinancialAdvisor: false,
              ),
            ),
          );
        },
        backgroundColor: Color(0xFFF8E4B2), // Light background for the button
        icon: Icon(Icons.chat, color: Color(0xFF1E1E1E)), // Dark icon color
        label: Text("Chat",
            style: TextStyle(color: Color(0xFF1E1E1E))), // Dark text color
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: advisorImage.isNotEmpty
                  ? NetworkImage(advisorImage) // Pass the imagePath URL
                  : NetworkImage(UserData().defaultImagePath),
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(width: 20), // Space between avatar and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisorName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF8E4B2), // Light text color for name
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      color: Colors.grey[800], // Set card color to grey
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5, // Increased elevation for a better shadow effect
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _getIconForTitle(title),
              color: Color(0xFFF8E4B2), // Light icon color
            ),
            SizedBox(width: 16), // Space between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16, // Increased font size for title
                      color: Color(0xFFF8E4B2), // Light text color for title
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Light color for content
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

  IconData _getIconForTitle(String title) {
    switch (title) {
      case "Occupation":
        return Icons.work;
      case "Email":
        return Icons.email;
      case "Phone":
        return Icons.phone;
      case "Age":
        return Icons.calendar_today;
      default:
        return Icons.info; // Default icon if title doesn't match
    }
  }
}
