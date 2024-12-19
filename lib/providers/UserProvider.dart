import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wise/models/User.dart';
import 'package:wise/models/SpendingCategory.dart';
import 'package:wise/repositories/UserRepository.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  List<SpendingCategory> _userCategories = []; // New: user-specific categories
  int _total = 0;
  int _valid = 0;
  int _invalid = 0;
  bool _isLoading = true;
  bool _isCategoryLoading = true; // Loading state for categories
  String? _errorMessage;

  List<User> get users => _users;
  List<SpendingCategory> get userCategories => _userCategories; // New getter
  int get total => _total;
  int get valid => _valid;
  int get invalid => _invalid;
  bool get isLoading => _isLoading;
  bool get isCategoryLoading =>
      _isCategoryLoading; // Getter for category loading state
  String? get errorMessage => _errorMessage;

  final UserRepository _userRepo = UserRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all users
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<User> users = await _userRepo.fetchAllUsers();

      // Count total, valid, and invalid users in the provider
      _total = users.length;
      _valid = users.where((user) => !user.isBan).length;
      _invalid = users.where((user) => user.isBan).length;

      _users = users;
    } catch (e) {
      _errorMessage = 'Error fetching data: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New: Fetch categories from the user's Category sub-collection
  Future<void> fetchUserCategories(String userId) async {
    _isCategoryLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch categories from the 'Category' sub-collection under the specific user's document
      QuerySnapshot categorySnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Category')
          .get();

      _userCategories = categorySnapshot.docs.map((doc) {
        return SpendingCategory(
          id: doc.id,
          name: doc['name'] ?? 'Unnamed Category',
          type: doc['type'] ?? 'Unknown Type',
          imagePath: doc['imagePath'] ?? '',
          createdAt:
              (doc['createdAt'] as Timestamp).toDate(), // Convert to DateTime
          updatedAt:
              (doc['updatedAt'] as Timestamp).toDate(), // Convert to DateTime
        );
      }).toList();
    } catch (e) {
      _errorMessage = 'Error fetching user categories: $e';
      print(_errorMessage);
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }
}
