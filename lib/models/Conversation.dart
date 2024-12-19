import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String sender;
  final String message;
  final DateTime timestamp;

  Message({
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      message: json['message'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}

class Conversation {
  final String id;
  final List<Message> userMessages;
  final List<Message> faMessages;
  final String userId;
  final String faId;
  final DateTime nextPaymentDate;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Conversation({
    required this.id,
    required this.userMessages,
    required this.faMessages,
    required this.userId,
    required this.faId,
    required this.nextPaymentDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  // Convert Firestore document to Conversation object
  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;

    var userMessages = (json['userMessage'] as List)
        .map((msg) => Message.fromJson(msg as Map<String, dynamic>))
        .toList();
    var faMessages = (json['faMessage'] as List)
        .map((msg) => Message.fromJson(msg as Map<String, dynamic>))
        .toList();

    return Conversation(
      id: doc.id,
      userMessages: userMessages,
      faMessages: faMessages,
      userId: (json['userID'] as DocumentReference).id,
      faId: (json['faID'] as DocumentReference).id,
      nextPaymentDate: (json['nextPaymentDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? false,
    );
  }
}
