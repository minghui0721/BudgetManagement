import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/Report.dart';

class ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Report>> getReportsByUserId(String userId) async {
    try {
      // Fetch reports based on userId
      var snapshot = await _firestore
          .collection('Reports')
          .where('userID', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching reports: $e');
      return []; // Return an empty list in case of error
    }
  }
}
