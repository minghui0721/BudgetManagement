import 'package:flutter/material.dart';
import 'package:wise/models/SpendingCategory.dart';
import 'package:wise/repositories/SpendingCategoryRepository.dart';

class SpendingCategoryProvider with ChangeNotifier {
  final SpendingCategoryRepository _spendingCategoryRepository =
     
      SpendingCategoryRepository();

  List<SpendingCategory> _categories = [];
  int _total = 0;
  int _expense = 0;
  int _income = 0;
  String? _errorMessage;
  bool _isLoading = false;

  List<SpendingCategory> get categories => _categories;
  int get total => _total;
  int get expense => _expense;
  int get income => _income;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchAllCategories() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _spendingCategoryRepository.getCategories();

      // Perform the counting logic in the provider
      _total = _categories.length;
      _expense =
          _categories.where((category) => category.type == "expense").length;
      _income =
          _categories.where((category) => category.type == "income").length;
    } catch (error) {
      _errorMessage = 'Error fetching spending categories: $error';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      _isLoading = false;
      notifyListeners();
    }
  }
}
