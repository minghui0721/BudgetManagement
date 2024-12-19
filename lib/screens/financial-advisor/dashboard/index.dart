import 'package:flutter/material.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/financial-advisor/components/AppBar.dart'; 
import 'package:wise/screens/financial-advisor/dashboard/partials/ProfileSection.dart';
import 'package:wise/screens/financial-advisor/dashboard/partials/QuickAccessSection.dart'; 

class FinancialAdvisorDashboard extends StatelessWidget {
  const FinancialAdvisorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar(isDashboard: true), 
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24.0), 
                const WelcomeSection(),
                const SizedBox(height: 24.0), 
                QuickAccessSection(faId: UserData().uid,),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
