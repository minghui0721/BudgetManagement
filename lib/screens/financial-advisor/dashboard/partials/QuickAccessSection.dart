import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/models/User.dart';
import 'package:wise/screens/financial-advisor/messages/partials/messages.dart';

class QuickAccessSection extends StatelessWidget {
  final String faId; // Pass the financial advisor ID

  const QuickAccessSection({super.key, required this.faId});

  Future<String?> _fetchAdvisorId(BuildContext context) async {
    return await Provider.of<FinancialAdvisorProvider>(
      context,
      listen: false,
    ).getAdvisorIdByUserId(faId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 23.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E4B2), // Updated background color
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Updated text color for visibility
            ),
          ),
          const SizedBox(height: 16.0),
          FutureBuilder<String?>(
            future: _fetchAdvisorId(context),
            builder: (context, advisorSnapshot) {
              if (advisorSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (advisorSnapshot.hasError || advisorSnapshot.data == null) {
                return Center(
                  child: Text(
                    'Error fetching advisor ID or ID not found.',
                    style: const TextStyle(color: Colors.black54),
                  ),
                );
              }

              final String advisorId = advisorSnapshot.data!;

              return FutureBuilder<List<User>>(
                future: Provider.of<FinancialAdvisorProvider>(context, listen: false)
                    .fetchApprovedRequests(faId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading members: ${snapshot.error}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No members found',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  } else {
                    List<User> members = snapshot.data!;
                    return Column(
                      children: members.map((member) {
                        return _buildMessageCard(
                          context,
                          member.name,
                          'Tap to start chat',
                          member.imagePath,
                          member.id,
                          advisorId,
                        );
                      }).toList(),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    String name,
    String message,
    String imagePath,
    String userId,
    String advisorId,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to the specific person's in-depth chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextChatPage(
              userId: userId, // Correct user ID
              faId: advisorId, // Use the provided financial advisor ID
              advisorName: name,
              isFinancialAdvisor: true, // Set true based on context (FA perspective)
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1e1e1e), // Updated box color
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.0,
              backgroundImage: imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
              backgroundColor: Colors.grey.shade200,
              child: imagePath.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 28.0,
                      color: Colors.black54,
                    )
                  : null,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8E4B2), // Updated text color for visibility
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFFF8E4B2), // Updated text color for visibility
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFF8E4B2), // Updated icon color for visibility
              size: 18.0,
            ),
          ],
        ),
      ),
    );
  }
}
