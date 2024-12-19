import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/Transactions.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> getTransactions() {
    return _firestore.collection("Transactions").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              TransactionModel.fromFirestore(doc)) // Use the correct method
          .toList();
    });
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestore.collection("Transactions").add(transaction.toJson());
  }

  Future<void> updateTransaction(
      String id, TransactionModel transaction) async {
    await _firestore
        .collection("Transactions")
        .doc(id)
        .update(transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    await _firestore.collection("Transactions").doc(id).delete();
  }
  
}
