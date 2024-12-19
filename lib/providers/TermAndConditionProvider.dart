import 'package:flutter/material.dart';
import 'package:wise/models/TermAndCondition.dart';
import 'package:wise/repositories/TermAndConditionRepository.dart';

class TermAndConditionProvider with ChangeNotifier {
  final TermAndConditionRepository _repository = TermAndConditionRepository();
  List<TermAndCondition> _termsAndConditions = [];
  bool _isLoading = false;

  List<TermAndCondition> get termsAndConditions => _termsAndConditions;
  bool get isLoading => _isLoading;

  int get total => _termsAndConditions.length;

  Future<void> fetchAllTermsAndConditions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _termsAndConditions = await _repository.getTermsAndConditions();
    } catch (error) {
      print('Error fetching terms and conditions: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
