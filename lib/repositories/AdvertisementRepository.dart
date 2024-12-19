import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/Advertisement.dart';

class AdvertisementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Advertisement>> getAdvertisements() async {
    var snapshot = await _firestore.collection('Advertisement').get();
    return snapshot.docs
        .map((doc) => Advertisement.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<void> create(Advertisement advertisement) async {
    try {
      await FirebaseFirestore.instance
          .collection('Advertisement')
          .doc(advertisement.id)
          .set({
        'merchantName': advertisement.merchantName,
        'adsTitle': advertisement.adsTitle,
        'images': advertisement.images,
        'startAt': advertisement.startAt,
        'endAt': advertisement.endAt,
        'createdAt': advertisement.createdAt,
        'updatedAt': advertisement.updatedAt,
      });
    } catch (e) {
      throw Exception('Failed to create advertisement: $e');
    }
  }

  Future<void> update(Advertisement updatedAdvertisement) async {
    try {
      await FirebaseFirestore.instance
          .collection('Advertisement')
          .doc(updatedAdvertisement.id)
          .update({
        'merchantName': updatedAdvertisement.merchantName,
        'adsTitle': updatedAdvertisement.adsTitle,
        'images': updatedAdvertisement.images,
        'startAt': Timestamp.fromDate(updatedAdvertisement.startAt),
        'endAt': Timestamp.fromDate(updatedAdvertisement.endAt),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update advertisement: $e');
    }
  }

  Future<void> delete(String advertisementId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Advertisement')
          .doc(advertisementId)
          .delete();
      await ImageHelper.deleteFolderFromStorage(
          'advertisements/$advertisementId');
    } catch (e) {
      throw Exception('Failed to delete advertisement: $e');
    }
  }
}
