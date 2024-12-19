import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/SpendingCategory.dart';

class SpendingCategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SpendingCategory>> getCategories() async {
    var snapshot = await _firestore.collection('SpendingCategory').get();
    return snapshot.docs
        .map((doc) => SpendingCategory.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addCategory(SpendingCategory category) async {
    await _firestore.collection('SpendingCategory').add({
      'name': category.name,
      'imagePath': category.imagePath,
      'type': category.type,
      'createdAt': Timestamp.fromDate(category.createdAt),
      'updatedAt': Timestamp.fromDate(category.updatedAt),
    });
  }

  static Future<void> create(SpendingCategory category) async {
    try {
      await FirebaseFirestore.instance
          .collection('SpendingCategory')
          .doc(category.id)
          .set({
        'name': category.name,
        'imagePath': category.imagePath,
        'type': category.type,
        'createdAt': category.createdAt,
        'updatedAt': category.updatedAt,
      });
    } catch (e) {
      throw Exception('Failed to create category');
    }
  }

  Future<void> update(SpendingCategory category) async {
    try {
      await _firestore.collection('SpendingCategory').doc(category.id).update({
        'name': category.name,
        'imagePath': category.imagePath,
        'type': category.type,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update category');
    }
  }

  Future<void> delete(String categoryId) async {
    try {
      await _firestore.collection('SpendingCategory').doc(categoryId).delete();
      await ImageHelper.deleteFolderFromStorage('categories/$categoryId');
    } catch (e) {
      print('Error delete category: $e');
    }
  }

    Future<List<SpendingCategory>> getUserCategories(String userId) async {
    var snapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Category')
        .get();

    return snapshot.docs
        .map((doc) => SpendingCategory.fromFirestore(doc.data(), doc.id))
        .toList();
  }

    // Method to add a new category to a user's sub-collection
  Future<void> addUserCategory(String userId, SpendingCategory category) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Category')
        .add({
      'name': category.name,
      'imagePath': category.imagePath,
      'type': category.type,
      'createdAt': Timestamp.fromDate(category.createdAt),
      'updatedAt': Timestamp.fromDate(category.updatedAt),
    });
  }
}
