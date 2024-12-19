import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/User.dart';

class Admin {
  final String id;
  final User user;

  Admin({
    required this.id,
    required this.user,
  });

  factory Admin.fromJson(Map<String, dynamic> json, String id, User user) {
    return Admin(
      id: id,
      user: user,
    );
  }
}
