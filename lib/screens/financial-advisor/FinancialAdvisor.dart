import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/screens/financial-advisor/reports-goals/index.dart';
import 'package:wise/screens/financial-advisor/components/BottomNavBar.dart';
import 'package:wise/screens/financial-advisor/messages/index.dart';
import 'package:wise/screens/financial-advisor/requests/index.dart';
import 'package:wise/screens/financial-advisor/dashboard/index.dart';
import 'package:wise/screens/financial-advisor/profile/index.dart';

class FinancialAdvisorScreen extends StatefulWidget {
  final int currentIndex;

  const FinancialAdvisorScreen({
    super.key,
    this.currentIndex = 0,
  });

  @override
  _FinancialAdvisorScreenState createState() => _FinancialAdvisorScreenState();
}

class _FinancialAdvisorScreenState extends State<FinancialAdvisorScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const FinancialAdvisorDashboard();
      case 1:
        return const FinancialAdvisorMessages();
      case 2:
        return const FinancialAdvisorRequests();
      case 3:
        return const FinancialAdvisorReportsGoals();
      case 4:
        return const FinancialAdvisorProfile();
      default:
        return const FinancialAdvisorDashboard(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      body: _getSelectedPage(), 
      bottomNavigationBar: SizedBox(
        child: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }
}
