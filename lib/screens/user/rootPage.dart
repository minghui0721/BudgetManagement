import 'package:flutter/material.dart';
import 'package:wise/screens/user/wallet/wallet.dart';
import 'package:wise/screens/user/reports/reports.dart';
import 'package:wise/screens/user/addTransaction/addTransaction.dart';
import 'package:wise/screens/user/profile/profile.dart';
import 'package:wise/screens/user/home/dashboard.dart';
import 'package:wise/screens/user/components/navBar.dart';

class RootPage extends StatefulWidget {
  final int currentIndex;
  final bool isConnected;
  final String? showSnackBarMessage;

  RootPage({
    this.currentIndex = 0,
    this.showSnackBarMessage,
    this.isConnected = false,
  });

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex;

  _RootPageState() : _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;

    // Show the SnackBar if a message is provided
    if (widget.showSnackBarMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.showSnackBarMessage!,
              style: TextStyle(color: Colors.white), // White text color
            ),
            backgroundColor: Colors.blueAccent, // Set background color to blue
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      BudgetTrackerPage(),
      WalletPage(isConnected: widget.isConnected),
      AddTransactionPage(),
      ReportsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0b0f12),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: WiseBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return; // Prevent reloading the same page
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
