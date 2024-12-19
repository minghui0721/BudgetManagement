import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/User.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/financial-advisor/profile/partial/view-member/member.dart';

class BriefMembersPage extends StatelessWidget {
  final String faId;

  const BriefMembersPage({super.key, required this.faId});

  @override
  Widget build(BuildContext context) {
    final financialAdvisorProvider = Provider.of<FinancialAdvisorProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e),
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Members',
            style: TextStyle(
              color: Color(0xFFF8E4B2),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1e1e1e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: financialAdvisorProvider.fetchApprovedRequests(faId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No approved members found.'));
          } else {
            final members = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberDetailPage(
                          name: member.name,
                          phoneNumber: member.phoneNumber,
                          email: member.email,
                          age: member.age.toString(),
                          imagePath: member.imagePath,
                          occupation: member.occupation, userId: UserData().uid,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
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
                          radius: 30.0,
                          backgroundImage: member.imagePath.isNotEmpty
                              ? NetworkImage(member.imagePath)
                              : null,
                          backgroundColor: member.imagePath.isEmpty ? Colors.white24 : Colors.transparent,
                          child: member.imagePath.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30.0,
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
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF8E4B2),
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                member.phoneNumber,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                member.email,
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
            );
          }
        },
      ),
    );
  }
}
