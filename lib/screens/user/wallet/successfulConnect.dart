import 'package:flutter/material.dart';
import 'package:wise/screens/user/rootPage.dart';

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Successfully connected",
              style: TextStyle(
                color: Color(0xFFF8E4B2),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Your bank account has been\nconnected successfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF8E4B2),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              onPressed: () {
                // Navigate to the RootPage with the WalletPage index and isConnected set to true
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => RootPage(
                      currentIndex: 1,
                      isConnected: true, // Set the connection status to true
                      showSnackBarMessage:
                          "Bank connected successfully", // Optional: show a message
                    ),
                  ),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
