import 'package:cloud_firestore/cloud_firestore.dart';

class Advertisement {
  String id;
  String merchantName;
  String adsTitle;
  List<String> images;
  DateTime startAt;
  DateTime endAt;
  DateTime createdAt;
  DateTime updatedAt;

  Advertisement({
    required this.id,
    required this.merchantName,
    required this.adsTitle,
    required this.images,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Advertisement.fromFirestore(Map<String, dynamic> data, String id) {
    return Advertisement(
      id: id,
      merchantName: data['merchantName'] ?? '',
      adsTitle: data['adsTitle'] ?? '',
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      startAt: data['startAt'] != null
          ? (data['startAt'] as Timestamp).toDate()
          : DateTime.now(),
      endAt: data['endAt'] != null
          ? (data['endAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantName': merchantName,
      'adsTitle': adsTitle,
      'images': images,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
