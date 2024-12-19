import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/SpendingCategoryProvider.dart';
import 'package:wise/screens/admin/advertisement/AdvertisementSlider.dart';
import 'package:wise/screens/user/addTransaction/reviewTransaction.dart';
import 'package:wise/screens/user/addTransaction/scanReceipt.dart';
import 'package:wise/screens/user/addTransaction/voiceInputTransaction.dart'; // Import the voice input page

class AddTransactionPage extends StatelessWidget {
  // Get the current time and date
// Combine date and time into a DateTime object directly
  DateTime transactionDateTime = DateTime.now();

  final bool showAdvertisement;

  AddTransactionPage({this.showAdvertisement = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Column(
        children: [
          if (showAdvertisement)
            AdvertisementSlider(), // Show only if `showAdvertisement` is true
          SizedBox(height: 10.0), // Add margin space above the AppBar
          AppBar(
            title: Text(
              'Add Transaction',
              style: TextStyle(
                color: Color(0xFFF8E4B2),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0xFF1E1E1E),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                children: [
                  SizedBox(
                      height:
                          0.0), // Add margin space above the Add Transaction content
                  Expanded(
                    child: ListView(
                      children: [
                        _buildOptionCard(
                          context,
                          'Scan Receipt',
                          'assets/images/addTransaction/scanReceipt.jpg',
                          () {
                            // Handle Scan Receipt click
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ScanReceiptPage()),
                            );
                          },
                        ),
                        SizedBox(height: 40),
                        _buildOptionCard(
                          context,
                          'Enter Manually',
                          'assets/images/addTransaction/enterManually.jpg',
                          () {
                            // Handle Enter Manually click
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewTransactionPage(
                                  amount: '', // Set to empty or null initially
                                  description:
                                      '', // Set to empty or null initially
                                  transactionDateTime:
                                      transactionDateTime, // Pass the DateTime object here
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 40),
                        _buildOptionCard(
                          context,
                          'Voice Input',
                          'assets/images/addTransaction/voiceInput.jpg',
                          () {
                            // Handle Voice Input click
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VoiceInputTransactionPage()), // Navigate to Voice Input Page
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String imagePath,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.4),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
