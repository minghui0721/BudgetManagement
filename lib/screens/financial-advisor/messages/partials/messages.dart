import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/Conversation.dart';

class TextChatPage extends StatefulWidget {
  final String userId;
  final String faId;
  final String advisorName;
  final bool isFinancialAdvisor;

  TextChatPage({
    required this.userId,
    required this.faId,
    required this.advisorName,
    required this.isFinancialAdvisor,
  });

  @override
  _TextChatPageState createState() => _TextChatPageState();
}

class _TextChatPageState extends State<TextChatPage> {
  final TextEditingController messageController = TextEditingController();
  final CollectionReference conversationsRef =
      FirebaseFirestore.instance.collection('Conversations');
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Print userId and faId for debugging
    print('User ID: ${widget.userId}');
    print('Financial Advisor ID: ${widget.faId}');
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendMessage(DocumentReference conversationDoc) {
    String text = messageController.text.trim();
    if (text.isNotEmpty) {
      String messageField =
          widget.isFinancialAdvisor ? 'faMessage' : 'userMessage';

      Timestamp currentTimestamp = Timestamp.now();

      conversationDoc.update({
        messageField: FieldValue.arrayUnion([
          {
            'sender': widget.isFinancialAdvisor ? 'FA' : 'User',
            'message': text,
            'timestamp': currentTimestamp,
          }
        ]),
        'updatedAt': currentTimestamp,
      });
      messageController.clear();
      _scrollToBottom(); // Scroll to the bottom after sending a message
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Widget _buildMessageBubble(Message message) {
    bool isSentByCurrentUser =
        (widget.isFinancialAdvisor && message.sender == 'FA') ||
        (!widget.isFinancialAdvisor && message.sender == 'User');

    return Align(
      alignment:
          isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isSentByCurrentUser ? Color(0xFF4A90E2) : Color(0xFFE0E0E0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isSentByCurrentUser ? Radius.circular(12) : Radius.zero,
            bottomRight:
                isSentByCurrentUser ? Radius.zero : Radius.circular(12),
          ),
        ),
        child: Text(
          message.message,
          style: TextStyle(
            color: isSentByCurrentUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Print userId and faId when the widget builds for further debugging
    print('Building TextChatPage for User ID: ${widget.userId} and FA ID: ${widget.faId}');
    
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(
          widget.advisorName,
          style:
              TextStyle(color: Color(0xFFF8E4B2), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1E1E1E),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: conversationsRef
                  .where('userID',
                      isEqualTo: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(widget.userId))
                  .where('faID',
                      isEqualTo: FirebaseFirestore.instance
                          .collection('FinancialAdvisors')
                          .doc(widget.faId))
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No conversation found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                DocumentSnapshot conversationDoc = snapshot.data!.docs.first;
                Conversation conversation =
                    Conversation.fromFirestore(conversationDoc);

                List<Message> allMessages = [
                  ...conversation.userMessages,
                  ...conversation.faMessages
                ];

                allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    itemCount: allMessages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(allMessages[index]);
                    },
                  ),
                );
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: conversationsRef
                .where('userID',
                    isEqualTo: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(widget.userId))
                .where('faID',
                    isEqualTo: FirebaseFirestore.instance
                        .collection('FinancialAdvisors')
                        .doc(widget.faId))
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SizedBox();
              }

              DocumentReference conversationDoc =
                  snapshot.data!.docs.first.reference;
              return _buildInputArea(conversationDoc: conversationDoc);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea({required DocumentReference conversationDoc}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade600),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12.0),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: () => _sendMessage(conversationDoc),
            backgroundColor: Color(0xFFF8E4B2),
            child: Icon(Icons.send, color: Colors.black),
            mini: true,
            elevation: 2,
          ),
        ],
      ),
    );
  }
}
