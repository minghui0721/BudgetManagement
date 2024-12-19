import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/models/Conversation.dart';
import 'package:wise/models/FinancialAdvisor.dart';
import 'package:wise/models/User.dart';
import 'package:wise/screens/admin/components/AppBar.dart';

class ConversationScreen extends StatefulWidget {
  final Conversation conversation;
  final User? user;
  final FinancialAdvisor? advisor;
  final bool isFromUser;

  const ConversationScreen({
    Key? key,
    required this.conversation,
    this.user,
    this.advisor,
    required this.isFromUser,
  }) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    // Scroll to the bottom when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

    @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the controller when done
    super.dispose();
  }


    // Function to scroll to the bottom of the list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}"; // Customize date format as needed
  }

  // Function to determine if a new date header should be displayed
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    List<Message> allMessages = [
      ...widget.conversation.userMessages,
      ...widget.conversation.faMessages,
    ];

    allMessages.sort((a, b) =>
        a.timestamp.compareTo(b.timestamp)); // Sort messages by timestamp

    DateTime? lastDate; // To keep track of the last displayed date
    // Track the latest message index for both user and advisor
    int latestUserMessageIndex =
        allMessages.lastIndexWhere((message) => message.sender == 'User');
    int latestAdvisorMessageIndex =
        allMessages.lastIndexWhere((message) => message.sender == 'FA');

    return Scaffold(
      appBar: AdminAppBar(
        title: widget.isFromUser
            ? 'Conversation with ${widget.advisor?.user.name ?? widget.conversation.faId}'
            : 'Conversation with ${widget.user?.name ?? widget.conversation.userId}',
        showBackButton: true,
      ),
      backgroundColor: AppColors.mediumGray,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                            controller: _scrollController, // Attach controller here

              padding: EdgeInsets.symmetric(vertical: 23.0),
              itemCount: allMessages.length,
              itemBuilder: (context, index) {
                final message = allMessages[index];
                bool isUserMessage = message.sender == 'User';

                // Check if we need to display a date header
                bool showDateHeader = lastDate == null ||
                    !_isSameDate(lastDate!, message.timestamp);
                if (showDateHeader) {
                  lastDate = message
                      .timestamp; // Update lastDate to the current message's date
                }

                // Determine if the image should be displayed beside the latest message only
                bool showUserImage =
                    isUserMessage && index == latestUserMessageIndex;
                bool showAdvisorImage =
                    !isUserMessage && index == latestAdvisorMessageIndex;

                return Column(
                  children: [
                    if (showDateHeader) // Display the date header if necessary
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _formatDate(message.timestamp),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: (widget.isFromUser && isUserMessage) ||
                                (!widget.isFromUser && !isUserMessage)
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Display image on the left side for left-aligned messages
                            if (((widget.isFromUser && !isUserMessage) ||
                                    (!widget.isFromUser && isUserMessage)) &&
                                ((showUserImage && widget.user != null) ||
                                    (showAdvisorImage &&
                                        widget.advisor != null)))
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  isUserMessage
                                      ? widget.user!.imagePath
                                      : widget.advisor!.user.imagePath,
                                ),
                              ),
                            if ((widget.isFromUser && !isUserMessage) ||
                                (!widget.isFromUser && isUserMessage))
                              SizedBox(
                                  width:
                                      8.0), // Space between image and message

                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: isUserMessage
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: isUserMessage
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.message,
                                      style: TextStyle(
                                          color: isUserMessage
                                              ? AppColors.secondary
                                              : Colors.white),
                                    ),
                                    SizedBox(
                                        height:
                                            4.0), // Add space between message and timestamp
                                    Text(
                                      _formatTime(message.timestamp),
                                      style: TextStyle(
                                          color: isUserMessage
                                              ? Colors.grey[800]
                                              : Colors.grey[300],
                                          fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Display image on the right side for right-aligned messages
                            if (((widget.isFromUser && isUserMessage) ||
                                    (!widget.isFromUser && !isUserMessage)) &&
                                ((showUserImage && widget.user != null) ||
                                    (showAdvisorImage &&
                                        widget.advisor != null)))
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    isUserMessage
                                        ? widget.user!.imagePath
                                        : widget.advisor!.user.imagePath,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to format the time
  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"; // Format time as HH:MM
  }
}
