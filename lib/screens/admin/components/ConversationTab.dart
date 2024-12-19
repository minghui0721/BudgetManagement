import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/models/Conversation.dart';
import 'package:wise/models/FinancialAdvisor.dart';
import 'package:wise/models/User.dart';
import 'package:wise/repositories/ConversationRepository.dart';
import 'package:wise/repositories/UserRepository.dart';
import 'package:wise/screens/admin/components/ConversationScreen.dart';
import 'package:wise/screens/admin/components/TableCard.dart';
import 'package:wise/repositories/FinancialAdvisorRepository.dart';

class ConversationTab extends StatefulWidget {
  final List<Conversation> conversations;
  final bool isFromUser;
  final User? user;
  final FinancialAdvisor? advisor;

  const ConversationTab({
    Key? key,
    required this.conversations,
    required this.isFromUser,
    this.user,
    this.advisor,
  }) : super(key: key);

  @override
  _ConversationTabState createState() => _ConversationTabState();
}

class _ConversationTabState extends State<ConversationTab> {
  List<FinancialAdvisor> financialAdvisors = [];
  List<User> users = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isFromUser) {
      _loadFinancialAdvisors();
    } else {
      _loadUsers();
    }
  }

  Future<void> _loadFinancialAdvisors() async {
    List<String> financialAdvisorIds =
        widget.conversations.map((conversation) => conversation.faId).toList();

    final advisors = await FinancialAdvisorRepository()
        .fetchFinancialAdvisorsByIds(financialAdvisorIds);

    setState(() {
      financialAdvisors = advisors;
      isLoading = false;
    });
  }

  Future<void> _loadUsers() async {
    List<String> userIds = widget.conversations
        .map((conversation) => conversation.userId)
        .toList();

    final fetchedUsers = await UserRepository().fetchUsersByIds(userIds);

    setState(() {
      users = fetchedUsers;
      isLoading = false;
    });
  }

  void _onViewConversation(String userId, String faId) async {
    final foundConversation =
        await ConversationRepository().findConversationByIds(
      conversations: widget.conversations,
      userId: userId,
      faId: faId,
    );

    if (foundConversation != null) {
      // Fetch user data using the userId from the found conversation
      List<User> users =
          await UserRepository().fetchUsersByIds([foundConversation.userId]);
      List<FinancialAdvisor> advisors = await FinancialAdvisorRepository()
          .fetchFinancialAdvisorsByIds([foundConversation.faId]);

      User? user; // Initialize user as nullable
      if (users.isNotEmpty) {
        user = users.first; // Get the first user from the list
      }
      FinancialAdvisor? advisor;
      if (advisors.isNotEmpty) {
        advisor = advisors.first; // Get the first user from the list
      }
      // Navigate to the ConversationScreen with both conversation and user
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationScreen(
            conversation: foundConversation,
            user: user,
            advisor: advisor,
            isFromUser: widget.isFromUser,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFromUser && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if there are any conversations
    if (widget.conversations.isEmpty) {
      return Center(
        child: Text(
          'No Conversation found',
          style: TextStyle(fontSize: 18, color: AppColors.lightTextGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      itemCount: widget.isFromUser ? financialAdvisors.length : users.length,
      itemBuilder: (context, index) {
        if (widget.isFromUser) {
          final advisor = financialAdvisors[index];
          return TableCard(
            imagePath: advisor.user.imagePath,
            title: Text(advisor.user.name),
            details: [
              Text('Email: ${advisor.user.email}'),
              Text('Phone: ${advisor.user.phoneNumber}'),
            ],
            onView: () => _onViewConversation(widget.user!.id, advisor.id),
          );
        } else {
          final user = users[index];
          return TableCard(
            imagePath: user.imagePath,
            title: Text(user.name),
            details: [
              Text('Email: ${user.email}'),
              Text('Phone: ${user.phoneNumber}'),
            ],
            onView: () => _onViewConversation(user.id, widget.advisor!.id),
          );
        }
      },
    );
  }
}
