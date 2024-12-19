import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String status;
  final String additionalComment;
  final Timestamp submitRequestTime;
  final Timestamp timeRespond;
  final DocumentReference? userId; 

  Request({
    required this.status,
    required this.additionalComment,
    required this.submitRequestTime,
    required this.timeRespond,
    required this.userId,
  });

  factory Request.fromDocument(DocumentSnapshot doc) {
    return Request(
      status: doc['Status'] ?? 'Pending',
      additionalComment: doc['additionalComment'] ?? '',
      submitRequestTime: doc['submitRequestTime'] ?? Timestamp.now(),
      timeRespond: doc['timeRespond'] ?? Timestamp.now(),
      userId: doc['userID'] is DocumentReference ? doc['userID'] : null,
    );
  }
}
