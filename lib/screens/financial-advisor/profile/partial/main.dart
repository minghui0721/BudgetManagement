import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/UserProvider.dart';
import 'package:wise/screens/financial-advisor/profile/partial/view-member/brief-members.dart';

class UserProfilePage extends StatelessWidget {
  final Function() onEditProfilePressed;
  final Function() onMembersPressed;
  final Function() onChangeRolePressed;
  final Function() onLogoutPressed;

  const UserProfilePage({
    super.key,
    required this.onEditProfilePressed,
    required this.onMembersPressed,
    required this.onChangeRolePressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoading = userProvider.isLoading;
    final errorMessage = userProvider.errorMessage;
    final users = userProvider.users; // Fetch all users

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1e1e1e),
        body: Center(child: CircularProgressIndicator()), // Loading indicator
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1e1e1e),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  userProvider.fetchAllUsers(); // Retry fetching users
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (users.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF1e1e1e),
        body: Center(child: Text('No Users Found')),
      );
    }

    // Display user data in the profile page
    final currentUser = users.first; // For demonstration, we take the first user

    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade800, // Background for profile card
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30.0, color: Colors.black), // Profile icon
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.name, // Show dynamic user name
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        currentUser.phoneNumber, // Show dynamic phone number
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        currentUser.email, // Show dynamic email
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Edit Profile button
            _buildProfileOption(
              context,
              icon: Icons.person,
              label: 'Edit Profile',
              onTap: onEditProfilePressed, // Navigate to the Edit Profile page
            ),

            // Members button
            _buildProfileOption(
              context,
              icon: Icons.group,
              label: 'Members',
              onTap: () {
                // Navigate to the Members page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BriefMembersPage(faId: '',), // Navigate to members page
                  ),
                );
              },
            ),

            // Change Role button
            _buildProfileOption(
              context,
              icon: Icons.account_box,
              label: 'Change Role',
              onTap: onChangeRolePressed, // Navigate to the Change Role page
            ),

            // Logout button
            _buildProfileOption(
              context,
              icon: Icons.logout,
              label: 'Logout',
              onTap: onLogoutPressed, // Handle logout functionality
            ),

            const SizedBox(height: 24.0), // Additional space if needed
          ],
        ),
      ),
    );
  }

  // Helper function to build each profile option
  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String label, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.black,
              child: Icon(icon, size: 24.0, color: Colors.amber), // Icon for the option
            ),
            const SizedBox(width: 16.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for the label
              ),
            ),
          ],
        ),
      ),
    );
  }
}
