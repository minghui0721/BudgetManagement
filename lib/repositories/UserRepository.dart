import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/User.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<User>> fetchAllUsers() async {
    List<User> users = [];
    Set<String> excludedUserIds = await _getExcludedUserIds();

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Users').get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String userId = doc.id;
        User user = User.fromJson(doc.data() as Map<String, dynamic>, userId);

        if (!excludedUserIds.contains(user.id)) {
          users.add(user); // Just collect users here
        }
      }
    } catch (e) {
      print('Error fetching Users: $e');
    }

    return users;
  }

  // New method to check if an email exists
  Future<bool> emailExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty; // Returns true if any user found
    } catch (e) {
      print('Error checking email existence: $e');
      return false; // Return false in case of an error
    }
  }

  Future<List<User>> fetchUsersByIds(List<String> ids) async {
    List<User> users = [];
    print("Fetching users with IDs: ${ids.join(', ')}");

    try {
      // Use whereIn to query multiple documents by their IDs
      QuerySnapshot userSnapshot = await _firestore
          .collection('Users')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      print("Number of users found: ${userSnapshot.docs.length}");

      for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
        String userId = userDoc.id;
        User user =
            User.fromJson(userDoc.data() as Map<String, dynamic>, userId);
        users.add(user); // Collect the user data
      }
    } catch (e) {
      print('Error fetching users by IDs: $e');
    }

    return users;
  }

  Future<Set<String>> _getExcludedUserIds() async {
    Set<String> excludedIds = {};

    try {
      QuerySnapshot advisorSnapshot =
          await _firestore.collection('FinancialAdvisors').get();
      for (QueryDocumentSnapshot advisorDoc in advisorSnapshot.docs) {
        String userId = advisorDoc['userID'].id;
        excludedIds.add(userId);
      }
    } catch (e) {
      print('Error fetching financial advisors: $e');
    }

    try {
      QuerySnapshot adminSnapshot = await _firestore.collection('Admins').get();
      for (QueryDocumentSnapshot adminDoc in adminSnapshot.docs) {
        String userId = adminDoc['userID'].id;
        excludedIds.add(userId);
      }
    } catch (e) {
      print('Error fetching admins: $e');
    }

    return excludedIds;
  }


// Method to create a new user in Firestore
static Future<void> createUser(User updatedUser) async {
  try {
    // Create a new user document in the 'users' collection
    await FirebaseFirestore.instance.collection('Users').doc(updatedUser.id).set({
      'name': updatedUser.name,
      'email': updatedUser.email,
      'phoneNumber': updatedUser.phoneNumber,
      'occupation': updatedUser.occupation,
      'password': updatedUser.password,
      'imagePath': updatedUser.imagePath,
      'age': updatedUser.age,
      'isBan': updatedUser.isBan,
      'address': {
        'unit': updatedUser.address.unit,
        'street': updatedUser.address.street,
        'city': updatedUser.address.city,
        'postalCode': updatedUser.address.postalCode,
        'state': updatedUser.address.state,
      },
      'createdAt': updatedUser.createdAt,
      'updatedAt': updatedUser.updatedAt,
    });
  } catch (e) {
    print('Error creating user: $e');
    throw Exception('Failed to create user');
  }
}


  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('Users').doc(user.id).update({
        'name': user.name,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'occupation': user.occupation,
        'age': user.age,
        'imagePath': user.imagePath,
        'address': {
          'unit': user.address.unit,
          'street': user.address.street,
          'city': user.address.city,
          'postalCode': user.address.postalCode,
          'state': user.address.state,
        },
        'isBan': user.isBan,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error updating financial advisor: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
  try {
    // Check if this user is a Financial Advisor
    QuerySnapshot advisorSnapshot = await _firestore
        .collection('FinancialAdvisors')
        .where('userID', isEqualTo: _firestore.doc('Users/$userId'))
        .get();

    // If user is a Financial Advisor, delete their advisor record as well
    if (advisorSnapshot.docs.isNotEmpty) {
      String advisorId = advisorSnapshot.docs.first.id;

      // Delete Financial Advisor document
      await _firestore.collection('FinancialAdvisors').doc(advisorId).delete();
    }

    // Delete User document
    await _firestore.collection('Users').doc(userId).delete();

    await ImageHelper.deleteFolderFromStorage('users/$userId');
    
  } catch (e) {
    print('Error deleting user: $e');
  }
}
}
