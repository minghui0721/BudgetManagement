import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  String id;
  String title;
  String content;
  String imagePath;
  DateTime createdAt;
  DateTime updatedAt;

  Notification({
    required this.id,
    required this.title,
    required this.content,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromFirestore(Map<String, dynamic> data, String id) {
    return Notification(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imagePath: data['imagePath'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
