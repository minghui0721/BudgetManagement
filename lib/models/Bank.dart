import 'package:cloud_firestore/cloud_firestore.dart';

class Bank {
  String id;
  String bankName;
  String imagePath;
  DateTime createdAt;
  DateTime updatedAt;

  Bank({
    required this.id,
    required this.bankName,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

factory Bank.fromFirestore(Map<String, dynamic> data, String id) {
  return Bank(
    id: id,
    bankName: data['bankName'] ?? '', 
    imagePath: data['imagePath'] ?? '',
    createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(), 
  );
}

Map<String, dynamic> toMap() {
  return {
    'bankName': bankName, 
    'imagePath': imagePath, 
    'createdAt': Timestamp.fromDate(createdAt), 
    'updatedAt': Timestamp.fromDate(updatedAt), 
  };
}
}
