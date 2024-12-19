import 'package:cloud_firestore/cloud_firestore.dart';

class TermAndCondition {
  String id;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  TermAndCondition({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TermAndCondition.fromFirestore(Map<String, dynamic> data, String id) {
    return TermAndCondition(
      id: id,
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
