import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/Goals.dart';
import 'package:wise/models/User.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/providers/GoalsProvider.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/financial-advisor/reports-goals/goals/goal.dart';

class BriefGoalsPage extends StatefulWidget {
  final String faId;

  const BriefGoalsPage({super.key, required this.faId});

  @override
  _BriefGoalsPageState createState() => _BriefGoalsPageState();
}

class _BriefGoalsPageState extends State<BriefGoalsPage> {
  bool isLoadingUsers = true;
  List<User> users = [];
  GoalProvider? goalProvider;

  @override
  void initState() {
    super.initState();
    goalProvider = Provider.of<GoalProvider>(context, listen: false);
    _fetchUsersUnderAdvisor();
  }

  Future<void> _fetchUsersUnderAdvisor() async {
    try {
      List<User> fetchedUsers = await Provider.of<FinancialAdvisorProvider>(
        context,
        listen: false,
      ).fetchApprovedRequests(widget.faId);

      setState(() {
        users = fetchedUsers;
        isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        isLoadingUsers = false;
      });
      print("Error fetching users under the advisor: $e");
    }
  }

  Future<void> _navigateToGoalPage(User user) async {
    List<Goal> userGoals = await goalProvider!.fetchGoalsByUserId(user.id);
    if (userGoals.isNotEmpty) {
      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GoalPage(
      goals: userGoals, // Pass the list of goals
      userId: UserData().uid, // Pass the user ID
    ),
  ),
);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No goals found for this user.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e),
      body: isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(
                  child: Text(
                    'No users found under this advisor.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Goals',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8E4B2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];

                          return GestureDetector(
                            onTap: () => _navigateToGoalPage(user),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              margin: const EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6.0,
                                    spreadRadius: 1.0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24.0,
                                    backgroundColor: Colors.amber.shade200,
                                    backgroundImage: user.imagePath != null
                                        ? NetworkImage(user.imagePath!)
                                        : null,
                                    child: user.imagePath == null
                                        ? const Icon(Icons.person, color: Colors.black)
                                        : null,
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Goal of ${user.name}',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFF8E4B2),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'View ${user.name.endsWith('s') ? user.name + '\'' : user.name + '\'s'} goals',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
