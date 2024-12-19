import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/models/User.dart';
import 'package:wise/screens/financial-advisor/messages/partials/messages.dart';

class BriefMessagesPage extends StatefulWidget {
  final String faId; // Financial advisor ID passed to the page
  const BriefMessagesPage({super.key, required this.faId});

  @override
  _BriefMessagesPageState createState() => _BriefMessagesPageState();
}

class _BriefMessagesPageState extends State<BriefMessagesPage> {
  String? advisorId; // Additional variable to store the advisor ID

  @override
  void initState() {
    super.initState();
    _setAdvisorId();
  }

  Future<void> _setAdvisorId() async {
    // Use the method to fetch the advisor ID based on the given userId
    String? fetchedAdvisorId = await Provider.of<FinancialAdvisorProvider>(
      context,
      listen: false,
    ).getAdvisorIdByUserId(widget.faId);

    if (fetchedAdvisorId != null) {
      setState(() {
        advisorId = fetchedAdvisorId;
      });
    } else {
      print("Failed to fetch the advisor ID.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e),
      body: advisorId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<User>>(
              future: Provider.of<FinancialAdvisorProvider>(context, listen: false)
                  .fetchApprovedRequests(widget.faId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading members: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No members found'));
                } else {
                  List<User> members = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      User member = members[index];

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TextChatPage(
                                    userId: member.id, // Ensure this matches the parameter in TextChatPage
                                    faId: advisorId!, // Ensure advisorId is not null
                                    advisorName: member.name, // Pass the correct name
                                    isFinancialAdvisor: true, // Set to true for financial advisors
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
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
                                    backgroundImage: member.imagePath.isNotEmpty
                                        ? NetworkImage(member.imagePath)
                                        : null,
                                    backgroundColor: member.imagePath.isEmpty ? Colors.amber : Colors.transparent,
                                    child: member.imagePath.isEmpty
                                        ? Text(
                                            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.name,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFF8E4B2),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Chat with ${member.name}',
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
                          ),
                          const SizedBox(height: 16.0), // Add spacing between items
                        ],
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
