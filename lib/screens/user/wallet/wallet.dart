import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise/screens/user/wallet/selectBank.dart';

class WalletPage extends StatefulWidget {
  bool isConnected;

  WalletPage({required this.isConnected});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  void _confirmDisconnect() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Confirm Disconnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure you want to disconnect from the bank?',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        _disconnect(); // Proceed with disconnecting
                      },
                      child: Text(
                        'Disconnect',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Define the _disconnect method here
  void _disconnect() {
    setState(() {
      widget.isConnected = false;
    });

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disconnected successfully'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(0xFF1E1E1E), // Set background color for the whole page
      body: Column(
        children: [
          SizedBox(height: 10.0), // Add margin above the AppBar
          widget.isConnected
              ? AppBar(
                  backgroundColor: Color(0xFF1E1E1E),
                  automaticallyImplyLeading:
                      false, // Disable the default back button
                  title: Text(
                    'Cards',
                    style: TextStyle(
                      color: Color(0xFFF8E4B2),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                              1000, 80, 0, 0), // Adjust position as needed
                          items: [
                            PopupMenuItem<String>(
                              value: 'disconnect',
                              child: Text('Disconnect'),
                            ),
                          ],
                          elevation: 8.0,
                        ).then((value) {
                          if (value == 'disconnect') {
                            _confirmDisconnect(); // Show confirmation dialog before disconnecting
                          }
                        });
                      },
                    )
                  ],
                )
              : Container(), // Only show AppBar if connected
          SizedBox(height: 10.0), // Add margin above the AppBar
          Expanded(
            child: widget.isConnected
                ? _buildConnectedUI(context)
                : _buildTermsAndConditionsUI(context),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Widget
        Center(
          child: Container(
            width: (MediaQuery.of(context).size.width) - 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA726), Color.fromARGB(255, 182, 162, 185)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.credit_card, color: Colors.white, size: 40),
                    Icon(Icons.wifi, color: Colors.white, size: 24),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  '1234 5678 9012 3456',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat('MM/yy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'GAN MING HUI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 30),
        // Available Balance
        Center(
          child: Column(
            children: [
              Text(
                'RM 2450.77',
                style: TextStyle(
                  color: Color(0xFFF8E4B2),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        // Container for Transactions Section with Red Background
        Expanded(
          child: Container(
            color: Color(0xFFF8E4B2),
            padding: EdgeInsets.all(16.0), // Padding inside the container
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transactions Section
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle See More action here
                      },
                      child: Text(
                        'See More',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                // Transaction List
                Expanded(
                  child: ListView(
                    children: [
                      TransactionItem(
                        category: 'Category 1',
                        date: 'Sep 02, 2022',
                        amount: 'RM 2000',
                        positive: true,
                        number: 1,
                      ),
                      TransactionItem(
                        category: 'Category 2',
                        date: 'Sep 01, 2022',
                        amount: '-RM 20',
                        positive: false,
                        number: 2,
                      ),
                      TransactionItem(
                        category: 'Category 3',
                        date: 'Aug 30, 2022',
                        amount: 'RM 50',
                        positive: true,
                        number: 3,
                      ),
                      // Add more TransactionItems here
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Function to build the Terms & Conditions UI
  Widget _buildTermsAndConditionsUI(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Center(
              child: Image.asset(
                'assets/images/logo/logoWithPadding.png',
                width: 80,
                height: 80,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Terms & Conditions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF333333),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: EdgeInsets.all(25.0),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  radius: Radius.circular(8.0),
                  thickness: 8.0,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'By utilizing the bank account connection feature of WISE, you agree to the following terms and conditions:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '1. Authorization:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        BulletPointText(
                          'By opting to connect your bank account to WISE, you authorize us to access and retrieve your financial transaction data from your linked bank account.',
                        ),
                        BulletPointText(
                          'You understand and acknowledge that this authorization grants us access to view and retrieve your transaction history, including but not limited to your account balances, transactions, and other financial information.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '2. Privacy and Security:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        BulletPointText(
                          'We prioritize the security and privacy of your financial information. Your data is encrypted and securely stored in accordance with industry standards.',
                        ),
                        BulletPointText(
                          'We will not share your financial information with third parties without your explicit consent, except as required by law or as outlined in our Privacy Policy.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '3. Accuracy and Reliability:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        BulletPointText(
                          'While we strive to provide accurate and reliable financial tracking services, we cannot guarantee the accuracy or completeness of the information retrieved from your bank account.',
                        ),
                        BulletPointText(
                          'You understand that your bank\'s policies and procedures may affect the availability or accuracy of the data retrieved by WISE.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '4. Usage and Restrictions:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        BulletPointText(
                          'You agree to use the bank account connection feature of WISE solely for personal financial management purposes.',
                        ),
                        BulletPointText(
                          'You shall not use this feature for any unlawful or unauthorized purposes, including but not limited to fraudulent activities or unauthorized access to bank accounts.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '5. Liability:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        BulletPointText(
                          'WISE and its affiliates shall not be held liable for any loss, damage, or inconvenience arising from the use of the bank account connection feature, including but not limited to errors in data retrieval, unauthorized access, or security breaches.',
                        ),
                        BulletPointText(
                          'You agree to indemnify and hold harmless WISE and its affiliates from any claims, losses, damages, liabilities, or expenses arising from your use of the bank account connection feature.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '6. Termination:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        BulletPointText(
                          'We reserve the right to suspend or terminate your access to the bank account connection feature at any time, without prior notice, if we suspect any unauthorized or fraudulent activity.',
                        ),
                        BulletPointText(
                          'You may also choose to disconnect your bank account from WISE at any time by accessing your account settings.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '7. Changes to Terms:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        BulletPointText(
                          'We reserve the right to update or modify these terms and conditions at any time. Any changes will be effective immediately upon posting on our website or within the app.',
                        ),
                        BulletPointText(
                          'It is your responsibility to review these terms periodically for any updates or changes.',
                        ),
                        SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF8E4B2),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1E1E1E),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.blueAccent,
                                            size: 60,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            "Confirm Acceptance",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Are you sure you want to accept the Terms & Conditions?",
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.grey[700],
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blueAccent,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BankSelectionPage(),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'Confirm',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              'I accept',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class TransactionItem extends StatelessWidget {
  final String category;
  final String date;
  final String amount;
  final bool positive;
  final int number;

  const TransactionItem({
    required this.category,
    required this.date,
    required this.amount,
    required this.positive,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: positive ? Colors.green : Colors.red,
            child: Text(
              '$number',
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            category,
            style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
          ),
          subtitle: Text(
            date,
            style: TextStyle(color: const Color.fromARGB(137, 255, 255, 255)),
          ),
          trailing: Text(
            amount,
            style: TextStyle(
              color: positive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class BulletPointText extends StatelessWidget {
  final String text;

  const BulletPointText(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
