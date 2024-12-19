import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/Bank.dart';

class BankRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Bank>> getBanks() async {
    var snapshot = await _firestore.collection('Bank').get();
    return snapshot.docs
        .map((doc) => Bank.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<void> createBank(Bank bank) async {
    try {
      await FirebaseFirestore.instance.collection('Bank').doc(bank.id).set({
        'bankName': bank.bankName,
        'imagePath': bank.imagePath,
        'createdAt': bank.createdAt,
        'updatedAt': bank.updatedAt,
      });
    } catch (e) {
      throw Exception('Failed to create bank');
    }
  }

  Future<void> updateBank(Bank updatedBank) async {
    try {
      await _firestore.collection('Bank').doc(updatedBank.id).update({
        'bankName': updatedBank.bankName,
        'imagePath': updatedBank.imagePath,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update bank');
    }
  }

  Future<void> deleteBank(String bankId) async {
    try {
      await _firestore.collection('Bank').doc(bankId).delete();
      await ImageHelper.deleteFolderFromStorage('banks/$bankId');
    } catch (e) {
      print('Error delete bank: $e');
    }
  }
}
