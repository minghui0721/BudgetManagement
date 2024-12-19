import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime createdAt;
  final String description;
  final DateTime transactionDate;
  final String type;
  final DocumentReference userId; // Change to DocumentReference

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.createdAt,
    required this.description,
    required this.transactionDate,
    required this.type,
    required this.userId,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id, // Store document ID
      amount: data['amount']?.toDouble() ?? 0.0,
      category: data['category'] ?? 'Unknown Category',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      type: data['type'] ?? '',
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "category": category,
      "createdAt": createdAt,
      "description": description,
      "transactionDate": transactionDate,
      "type": type,
      "userId": userId,
    };
  }
}
