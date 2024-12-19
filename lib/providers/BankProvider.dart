import 'package:flutter/material.dart';
import 'package:wise/models/Bank.dart';
import 'package:wise/repositories/BankRepository.dart';

class BankProvider with ChangeNotifier {
  final BankRepository _bankRepository = BankRepository();
  
  List<Bank> _banks = [];
  bool _isLoading = false; 

  List<Bank> get banks => _banks;

  int get totalBanks => _banks.length;

  bool get isLoading => _isLoading;

  Future<void> fetchAllBanks() async {
    _isLoading = true; 
    notifyListeners(); 

    try {
      _banks = await _bankRepository.getBanks();
    } catch (error) {
      print('Error fetching banks: $error');
    } finally {
      _isLoading = false; 
      notifyListeners();
    }
  }
}
