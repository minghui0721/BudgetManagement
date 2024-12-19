import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/Admin.dart';
import 'package:wise/models/User.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Admin?> isAdmin(String email) async {
    try {
      final userQuery = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return null;
      }

      final userDoc = userQuery.docs.first;
      final userId = userDoc.id;

      final adminData = await fetchAdminDataById(userId);

      return adminData;
    } catch (e) {
      return null;
    }
  }

  Future<Admin?> fetchAdminDataById(String userId) async {
    try {
      // Get the admin document by user ID
      final adminSnapshot = await _firestore
          .collection('Admins')
          .where('userID', isEqualTo: _firestore.doc('Users/$userId'))
          .limit(1)
          .get();

      if (adminSnapshot.docs.isEmpty) {
        return null;
      }

      // Get the user data from the Users collection
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (!userDoc.exists) {
        return null;
      }

      // Create User and Admin instances
      User user = User.fromJson(userDoc.data() as Map<String, dynamic>, userId);
      Admin admin = Admin.fromJson(
          adminSnapshot.docs.first.data() as Map<String, dynamic>,
          adminSnapshot.docs.first.id,
          user);

      return admin;
    } catch (e) {
      return null;
    }
  }

  Future<void> create(Admin admin) async {
    try {
      DocumentReference userRef =
          _firestore.collection('Users').doc(admin.user.id);

      await _firestore.collection('Admins').add({
        'userID': userRef,
      });
    } catch (e) {
      throw Exception('Failed to create admin');
    }
  }

  Future<void> update(Admin admin) async {
    try {
      await _firestore.collection('Users').doc(admin.user.id).update({
        'name': admin.user.name,
        'email': admin.user.email,
        'phoneNumber': admin.user.phoneNumber,
        'occupation': admin.user.occupation,
        'age': admin.user.age,
        'imagePath': admin.user.imagePath,
        'address': {
          'unit': admin.user.address.unit,
          'street': admin.user.address.street,
          'city': admin.user.address.city,
          'postalCode': admin.user.address.postalCode,
          'state': admin.user.address.state,
        },
        'isBan': admin.user.isBan,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error updating admin: $e');
    }
  }
}
