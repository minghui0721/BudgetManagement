import 'package:flutter/material.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/financial-advisor/components/AppBar.dart';
import 'package:wise/screens/financial-advisor/requests/partials/brief-requests.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';

class FinancialAdvisorRequests extends StatelessWidget {
  const FinancialAdvisorRequests({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure that UserData is initialized properly
    final String faId = UserData().uid;
    if (faId.isEmpty) {
      return const Center(
        child: Text('Error: Financial Advisor ID not found'),
      );
    }

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Custom height for AppBar
        child: CustomAppBar(isDashboard: false, title: 'Requests'), // Keeping your custom AppBar
      ),
      body: ChangeNotifierProvider(
        create: (context) => FinancialAdvisorProvider(),
        child: BriefRequestsPage(faId: faId), // Pass the valid faId here
      ),
    );
  }
}
