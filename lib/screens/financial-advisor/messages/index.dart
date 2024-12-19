import 'package:flutter/material.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/financial-advisor/components/AppBar.dart'; // Assuming you have a reusable AppBar component
import 'package:wise/screens/financial-advisor/messages/partials/brief-messages.dart'; // Importing brief messages

class FinancialAdvisorMessages extends StatelessWidget {
  const FinancialAdvisorMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Custom height for AppBar
        child: CustomAppBar(isDashboard: false, title: 'Messages'),
      ),
      body: BriefMessagesPage(faId: UserData().uid), // Using the BriefMessagesPage
    );
  }
}
