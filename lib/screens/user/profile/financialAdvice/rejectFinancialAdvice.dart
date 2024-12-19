import 'package:flutter/material.dart';

class RejectedPage extends StatelessWidget {
  final String rejectionReason;

  RejectedPage({required this.rejectionReason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Rejected")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your request was rejected for the following reason:",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              rejectionReason,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to advisor selection
              },
              child: Text("Select a Different Advisor"),
            ),
          ],
        ),
      ),
    );
  }
}
