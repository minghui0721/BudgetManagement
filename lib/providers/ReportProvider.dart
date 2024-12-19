import 'package:flutter/material.dart';
import 'package:wise/models/Report.dart';
import 'package:wise/repositories/ReportRepository.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _reportRepository = ReportRepository();
  
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

Future<void> fetchReportsByUserId(String userId) async {
  // Make sure this method accepts a single userId of type String
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    _reports = await _reportRepository.getReportsByUserId(userId);
  } catch (error) {
    _errorMessage = 'Error fetching reports: $error';
    print(_errorMessage);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  fetchReportCount(String faId) {}
}
