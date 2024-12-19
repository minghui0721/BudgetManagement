import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/User.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/screens/financial-advisor/reports-goals/reports/report.dart';

class BriefReportsPage extends StatefulWidget {
  final String faId; // The financial advisor ID passed as a string

  const BriefReportsPage({super.key, required this.faId});

  @override
  _BriefReportsPageState createState() => _BriefReportsPageState();
}

class _BriefReportsPageState extends State<BriefReportsPage> {
  bool isLoadingUsers = true;
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsersUnderAdvisor();
  }

  Future<void> _fetchUsersUnderAdvisor() async {
    try {
      // Fetch users approved under the financial advisor
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
                        'Report',
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
                            onTap: () async {
                              // Fetch the advisorId asynchronously
                              String? advisorId = await Provider.of<FinancialAdvisorProvider>(
                                context,
                                listen: false,
                              ).getAdvisorIdByUserId(widget.faId);

                              if (advisorId != null) {
                                // Navigate to the ReportPage with userId and advisorId
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReportPage(
                                      userId: user.id, // Correct user ID
                                      faId: advisorId, // Pass the fetched advisorId
                                    ),
                                  ),
                                );
                              } else {
                                // Show an error if advisorId couldn't be fetched
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to fetch advisor ID.'),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              margin: const EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white24, // Updated container color
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
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFF8E4B2), // Updated text color
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'View ${user.name.endsWith('s') ? user.name + '\'' : user.name + '\'s'} report', // Line showing 'View username's report'
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
