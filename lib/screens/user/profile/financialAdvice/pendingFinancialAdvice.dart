import 'package:flutter/material.dart';

class PendingPage extends StatelessWidget {
  final String advisorName;

  PendingPage({required this.advisorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        // Use SafeArea to handle padding above the AppBar
        top: true,
        child: Column(
          children: [
            AppBar(
              title: Text(
                "Request Pending",
                style: TextStyle(
                    color: Color(0xFFF8E4B2), fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(0xFF1E1E1E),
              centerTitle: true,
              elevation: 0,
              iconTheme:
                  IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty,
                          color: Color(0xFFF8E4B2), size: 80),
                      SizedBox(height: 20),
                      Text(
                        "Your request to $advisorName is pending.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please wait while $advisorName reviews your request. You will be notified once the status changes.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 30),
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFF8E4B2)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
