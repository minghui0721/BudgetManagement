import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wise/models/Transactions.dart';
import 'package:wise/repositories/TransactionRepository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> _transactions = []; // All transactions
  List<TransactionModel> _latest10Transactions =
      []; // Only the latest 10 transactions

  // Calculate the total income and total expense
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double get netBalance => totalIncome - totalExpense; // Calculate net balance

  // Only the latest 10 transactions
  List<TransactionModel> get latest10Transactions =>
      _transactions.take(10).toList();

  void fetchTransactions() async {
    try {
      // Get the current user's ID
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is currently logged in.");
        return;
      }

      // Get the reference to the current user's document in the 'Users' collection
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);

      final snapshot = await _firestore
          .collection('Transactions')
          .where('userId', isEqualTo: userRef) // Use the reference in the query
          .orderBy('transactionDate', descending: true)
          .get();

      final fetchedTransactions = snapshot.docs.map((doc) {
        return TransactionModel.fromFirestore(doc);
      }).toList();

      _transactions = fetchedTransactions;

      // Calculate total income and expense
      totalIncome = 0.0;
      totalExpense = 0.0;
      for (var transaction in _transactions) {
        if (transaction.type.toLowerCase() == 'income') {
          totalIncome += transaction.amount;
        } else if (transaction.type.toLowerCase() == 'expense') {
          totalExpense += transaction.amount;
        }
      }

      // Store only the latest 10 transactions for display
      _latest10Transactions = _transactions.take(10).toList();

      notifyListeners(); // Notify UI of updated totals and latest 10 transactions
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('Transactions').doc(transactionId).delete();
      fetchTransactions(); // Refresh the transaction list after deletion
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
    fetchTransactions(); // Refresh data after adding a transaction
  }

  Future<void> updateTransaction(
      String transactionId, Map<String, dynamic> newData) async {
    try {
      await _firestore
          .collection('Transactions')
          .doc(transactionId)
          .update(newData);
      fetchTransactions(); // Refresh the list after updating
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }

  Future<void> fetchTransactionsByUserIdAndDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final userReference = _firestore.collection('Users').doc(userId);
      final snapshot = await _firestore
          .collection('Transactions')
          .where('userId', isEqualTo: userReference)
          .where('transactionDate', isGreaterThanOrEqualTo: startDate)
          .where('transactionDate', isLessThanOrEqualTo: endDate)
          .orderBy('transactionDate', descending: true)
          .get();

      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Map<String, double> getCategoryTotals(bool isIncome) {
    Map<String, double> categoryTotals = {};

    for (var transaction in _transactions) {
      if (transaction.type.toLowerCase() == (isIncome ? 'income' : 'expense')) {
        final category = transaction.category;
        final amount = transaction.amount;

        if (categoryTotals.containsKey(category)) {
          categoryTotals[category] = categoryTotals[category]! + amount;
        } else {
          categoryTotals[category] = amount;
        }
      }
    }

    return categoryTotals;
  }
}
