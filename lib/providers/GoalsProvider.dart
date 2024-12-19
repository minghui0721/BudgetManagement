import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wise/models/Goals.dart';
import 'package:wise/repositories/GoalsRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalProvider with ChangeNotifier {
  final GoalRepository goalRepository = GoalRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Real-time subscription to Firestore changes
  StreamSubscription<List<Goal>>? _goalSubscription;

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Fetch goals with real-time updates
  void fetchGoals(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRef = _firestore.collection('Users').doc(userId);

      // Cancel any existing subscription to avoid multiple listeners
      _goalSubscription?.cancel();

      // Listen to real-time Firestore updates
      _goalSubscription = goalRepository.getGoals(userRef).listen((goalList) {
        _goals = goalList;
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        setErrorMessage('Error fetching goals: $e');
        _isLoading = false;
      });
    } catch (e) {
      setErrorMessage('Error initializing goal stream: $e');
      _isLoading = false;
    }
  }

  Future<void> addGoal(String userId, Goal goal) async {
    try {
      final userRef = _firestore.collection('Users').doc(userId);
      await goalRepository.addGoal(userRef, goal);
      // No need to call fetchGoals() here because the Firestore listener will detect the new goal
    } catch (e) {
      setErrorMessage('Error adding goal: $e');
    }
  }

  Future<void> addMoneyToGoal(String goalId, double amount) async {
    try {
      final goalDoc = _firestore.collection('Goals').doc(goalId);
      final goalSnapshot = await goalDoc.get();

      final currentAmount = goalSnapshot['currentAmount'] ?? 0.0;
      final targetAmount = goalSnapshot['targetAmount'] ?? double.infinity;

      if (currentAmount + amount > targetAmount) {
        throw Exception("Amount exceeds the target saving amount.");
      }

      // Update Firestore document, which will trigger the real-time listener
      await goalDoc.update({
        'currentAmount': currentAmount + amount,
      });
    } catch (e) {
      throw Exception("Failed to add money: $e");
    }
  }

  Future<void> updateGoal(String userId, Goal goal) async {
    try {
      await goalRepository.updateGoal(userId, goal);
      // Firestore listener will update _goals automatically, so no need for fetchGoals() here
    } catch (e) {
      setErrorMessage('Error updating goal: $e');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await goalRepository.deleteGoal(goalId);
      // No need to call fetchGoals here, the Firestore listener will handle the UI update.
    } catch (e) {
      setErrorMessage('Error deleting goal: $e');
      notifyListeners(); // Ensure the UI shows an error state if deletion fails
    }
  }

  Future<List<Goal>> fetchGoalsByUserId(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRef = _firestore.collection('Users').doc(userId);
      List<Goal> userGoals = await goalRepository.getGoalsOnce(userRef);

      _goals = userGoals;
      _isLoading = false;
      notifyListeners();
      return userGoals;
    } catch (e) {
      print("Error fetching goals for user $userId: $e");
      setErrorMessage('Error fetching goals: $e');
      _isLoading = false;
      return [];
    }
  }

  Future<int> fetchGoalCount(String faId) async {
    try {
      print("Fetching goal count for Financial Advisor ID: $faId");

      QuerySnapshot requestSnapshot = await _firestore
          .collection('FinancialAdvisors')
          .doc(faId)
          .collection('Request')
          .where('Status', isEqualTo: 'Approved')
          .get();

      List<DocumentReference> userRefs = requestSnapshot.docs
          .map((doc) => doc['userID'] as DocumentReference)
          .toList();

      if (userRefs.isEmpty) {
        print("No user references found for the advisor.");
        return 0;
      }

      int totalGoalsCount = 0;

      for (DocumentReference userRef in userRefs) {
        QuerySnapshot goalsSnapshot = await _firestore
            .collection('Goals')
            .where('userRef', isEqualTo: userRef)
            .get();

        totalGoalsCount += goalsSnapshot.size;
      }

      print("Total goals count: $totalGoalsCount");
      return totalGoalsCount;
    } catch (e) {
      print("Error fetching goal count: $e");
      return 0;
    }
  }

  @override
  void dispose() {
    _goalSubscription?.cancel(); // Cancel Firestore listener on dispose
    super.dispose();
  }
}
