import 'package:flutter/material.dart';
import 'package:wise/models/Notification.dart' as wise_notifications; // Add prefix
import 'package:wise/repositories/NotificationRepository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _notificationRepository = NotificationRepository();
  
  List<wise_notifications.Notification> _notifications = [];
  bool _isLoading = false; 

  List<wise_notifications.Notification> get notifications => _notifications; 

  bool get isLoading => _isLoading;

  int get totalNotifications => _notifications.length; 

  Future<void> fetchAllNotifications() async {
    _isLoading = true; 
    notifyListeners(); 

    try {
      _notifications = await _notificationRepository.getNotifications();
    } catch (error) {
      print('Error fetching notifications: $error');
    } finally {
      _isLoading = false; 
      notifyListeners(); 
    }
  }
}
