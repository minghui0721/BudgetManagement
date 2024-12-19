import 'package:flutter/material.dart';
import 'package:wise/helper/DateTimeHelper.dart';
import 'package:wise/models/Advertisement.dart';
import 'package:wise/repositories/AdvertisementRepository.dart';

class AdvertisementProvider with ChangeNotifier {
  List<Advertisement> _advertisements = [];
  int _total = 0;
  int _inPeriod = 0;
  int _outPeriod = 0;
  int _future = 0;
  bool _isLoading = true;

  String? _errorMessage;

  List<Advertisement> get advertisements => _advertisements;
  int get total => _total;
  int get inPeriod => _inPeriod;
  int get outPeriod => _outPeriod;
  int get future => _future;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final AdvertisementRepository _advertisementRepo = AdvertisementRepository();

  Future<void> fetchAllAdvertisments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<Advertisement> advertisements =
          await _advertisementRepo.getAdvertisements();

      // Perform the counting logic in the provider
      _total = advertisements.length;
      _inPeriod = advertisements.where((advertisement) => advertisement.startAt.isBefore(DateTimeHelper.now) && advertisement.endAt.isAfter(DateTimeHelper.now)).length;
      _outPeriod = advertisements.where((advertisement) => advertisement.endAt.isBefore(DateTimeHelper.now)).length;
      _future = advertisements.where((advertisement) => advertisement.startAt.isAfter(DateTimeHelper.now) && advertisement.endAt.isAfter(DateTimeHelper.now)).length;

      _advertisements = advertisements;
    } catch (e) {
      _errorMessage = 'Error fetching data: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
