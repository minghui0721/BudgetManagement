import 'package:flutter/material.dart';

class PendingRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Column(
        children: [
          SizedBox(height: 15), // Add 20px space above the AppBar
          AppBar(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            title: Text(
              "Pending Approval",
              style: TextStyle(
                  color: Color(0xFFF8E4B2), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.amber, size: 50),
                    SizedBox(height: 20),
                    Text(
                      "Your request to become a Financial Advisor is pending approval.",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "You will be notified once your request has been reviewed.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
