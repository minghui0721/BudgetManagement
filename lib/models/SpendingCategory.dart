import 'package:cloud_firestore/cloud_firestore.dart';

class SpendingCategory {
  String id;
  String name;
  String type;
  String imagePath;

  DateTime createdAt;
  DateTime updatedAt;

  SpendingCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpendingCategory.fromFirestore(Map<String, dynamic> data, String id) {
    return SpendingCategory(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      imagePath: data['imagePath'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagePath': imagePath,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
