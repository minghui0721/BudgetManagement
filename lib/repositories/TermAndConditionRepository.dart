import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/TermAndCondition.dart';

class TermAndConditionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TermAndCondition>> getTermsAndConditions() async {
    var snapshot = await _firestore.collection('TermAndCondition').get();
    return snapshot.docs
        .map((doc) => TermAndCondition.fromFirestore(doc.data(), doc.id))
        .toList();
  }

      static Future<void> create(TermAndCondition tac) async {
    try {
      await FirebaseFirestore.instance.collection('TermAndCondition').doc(tac.id).set({
        'content': tac.content,
        'createdAt': tac.createdAt,
        'updatedAt': tac.updatedAt,
      });
    } catch (e) {
      throw Exception('Failed to create TermAndCondition');
    }
  }

  Future<void> update(TermAndCondition tac) async {
    try {
      await _firestore.collection('TermAndCondition').doc(tac.id).update({
        'content': tac.content,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update TermAndCondition');
    }
  }

  Future<void> delete(String tacId) async {
    try {
      await _firestore.collection('TermAndCondition').doc(tacId).delete();
      await ImageHelper.deleteFolderFromStorage('categories/$tacId');
    } catch (e) {
      print('Error delete TermAndCondition: $e');
    }
  }
}
