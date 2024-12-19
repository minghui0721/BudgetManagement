import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/User.dart';

class FinancialAdvisor {
  final String id;
  final User user;
  final bool isVerified;
  final String rejectReason;
  final String icImageFront;
  final String icImageBack;

  FinancialAdvisor({
    required this.id,
    required this.user,
    required this.isVerified,
    required this.rejectReason,
    required this.icImageFront,
    required this.icImageBack,
  });

  factory FinancialAdvisor.fromJson(
      Map<String, dynamic> json, String id, User user) {
    return FinancialAdvisor(
      id: id,
      user: user,
      isVerified: json['isVerified'] ?? '',
      rejectReason: json['rejectReason'] ?? '',
      icImageFront: json['icImageFront'] ?? '',
      icImageBack: json['icImageBack'] ?? '',
    );
  }
}
