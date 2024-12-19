import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/Notification.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Notification>> getNotifications() async {
    var snapshot = await _firestore.collection('Notification').get();
    return snapshot.docs
        .map((doc) => Notification.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<void> create(Notification notification) async {
    try {
      await FirebaseFirestore.instance
          .collection('Notification')
          .doc(notification.id)
          .set({
        'title': notification.title,
        'content': notification.content,
        'imagePath': notification.imagePath,
        'createdAt': notification.createdAt,
        'updatedAt': notification.updatedAt,
      });
    } catch (e) {
      throw Exception('Failed to create notification');
    }
  }

  Future<void> update(Notification updatedNotification) async {
    try {
      await _firestore.collection('Notification').doc(updatedNotification.id).update({
        'title': updatedNotification.title,
        'content': updatedNotification.content,
        'imagePath': updatedNotification.imagePath,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update notification');
    }
  }

  Future<void> delete(String notificationId) async {
    try {
      await _firestore.collection('Notification').doc(notificationId).delete();
      await ImageHelper.deleteFolderFromStorage(
          'notifications/$notificationId');
    } catch (e) {
      print('Error delete notification: $e');
    }
  }
}
