import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final DocumentReference userRef;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    required this.userRef,
  });

  // Modify fromJson to handle int values as doubles
  factory Goal.fromJson(String id, Map<String, dynamic> json) {
    return Goal(
      id: id,
      name: json['name'],
      targetAmount: (json['targetAmount'] as num).toDouble(), // Cast to double
      currentAmount:
          (json['currentAmount'] as num).toDouble(), // Cast to double
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      isCompleted: json['isCompleted'] ?? false,
      userRef: json['userRef'] as DocumentReference,
    );
  }

  get income => null;

  get expenses => null;

  get saving => null;

  String? get additionalComments => null;

  get userId => null;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'startDate': startDate,
      'endDate': endDate,
      'isCompleted': isCompleted,
      'userRef': userRef,
    };
  }
}
