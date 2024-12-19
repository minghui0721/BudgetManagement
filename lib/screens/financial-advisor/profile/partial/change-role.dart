import 'package:flutter/material.dart';
import 'package:wise/screens/user/User.dart';
import 'package:wise/screens/user/rootPage.dart';

class ChangeRolePage extends StatelessWidget {
  const ChangeRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        elevation: 0,
        title: const Text(
          'Change Role',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showChangeRoleDialog(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          child: const Text(
            'Change Role to User',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Role'),
          content:
              const Text('Are you sure you want to change your role to User?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RootPage(currentIndex: 0), // Navigate to RootPage
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
