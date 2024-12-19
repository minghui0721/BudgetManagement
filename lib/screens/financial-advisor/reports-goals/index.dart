import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/GoalsProvider.dart';
import 'package:wise/providers/ReportProvider.dart';
import 'package:wise/screens/financial-advisor/components/AppBar.dart';
import 'package:wise/screens/financial-advisor/reports-goals/reports/brief-reports.dart';
import 'package:wise/screens/financial-advisor/reports-goals/goals/brief-goals.dart';
import 'package:wise/providers/userGlobalVariables.dart'; // Import userGlobalVariables if you need user ID

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()), // Add GoalProvider
      ],
      child: MaterialApp(
        title: 'Financial Advisor Reports & Goals',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: const FinancialAdvisorReportsGoals(),
      ),
    );
  }
}

class FinancialAdvisorReportsGoals extends StatelessWidget {
  const FinancialAdvisorReportsGoals({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch user ID from UserData for demonstration purposes
    String userId = UserData().uid;

    // Ensure goals are fetched when this widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalProvider>(context, listen: false).fetchGoals(userId);
    });

    return DefaultTabController(
      length: 2, // Two tabs: Reports and Goals
      child: Column(
        children: [
          const CustomAppBar(isDashboard: false, title: 'Reports and Goals'), // Custom header
          Expanded(
            child: Column(
              children: [
                // TabBar for Reports and Goals
                const TabBar(
                  labelColor: Colors.grey, // Set label color to grey
                  unselectedLabelColor: Colors.grey, // Keep unselected label color grey too
                  indicatorColor: Color(0xFFF9E5C0), // Indicator color matching the design
                  tabs: [
                    Tab(text: 'Reports'), // First tab
                    Tab(text: 'Goals'), // Second tab
                  ],
                ),
                // TabBarView to display the respective page content
                Expanded(
                  child: TabBarView(
                    children: [
                      BriefReportsPage(faId: UserData().uid,), // Shows reports component
                      BriefGoalsPage(faId: UserData().uid,),   // Shows goals component
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
