import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/FinancialAdvisor.dart';
import 'package:wise/models/User.dart';

class FinancialAdvisorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FinancialAdvisor>> fetchAllFinancialAdvisors() async {
    List<FinancialAdvisor> advisors = [];

    try {
      QuerySnapshot advisorSnapshot =
          await _firestore.collection('FinancialAdvisors').get();

      for (QueryDocumentSnapshot advisorDoc in advisorSnapshot.docs) {
        DocumentReference userRef = advisorDoc['userID'];
        DocumentSnapshot userDoc = await userRef.get();

        if (userDoc.exists) {
          User user =
              User.fromJson(userDoc.data() as Map<String, dynamic>, userRef.id);

          FinancialAdvisor advisor = FinancialAdvisor.fromJson(
              advisorDoc.data() as Map<String, dynamic>, advisorDoc.id, user);

          advisors.add(advisor);
        }
      }
    } catch (e) {
      print('Error fetching financial advisors: $e');
    }

    return advisors;
  }

  Future<List<FinancialAdvisor>> fetchFinancialAdvisorsByIds(
      List<String> ids) async {
    List<FinancialAdvisor> advisors = [];
    try {
      QuerySnapshot advisorSnapshot = await _firestore
          .collection('FinancialAdvisors')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      for (QueryDocumentSnapshot advisorDoc in advisorSnapshot.docs) {
        String userId = advisorDoc['userID'].id;

        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(userId).get();

        User user =
            User.fromJson(userDoc.data() as Map<String, dynamic>, userId);

        FinancialAdvisor advisor = FinancialAdvisor.fromJson(
            advisorDoc.data() as Map<String, dynamic>, advisorDoc.id, user);

        advisors.add(advisor);
      }
    } catch (e) {
      print('Error fetching financial advisors by IDs: $e');
    }
    return advisors;
  }

  Future<void> deleteFinancialAdvisor(String advisorId) async {
    try {
      DocumentSnapshot advisorDoc =
          await _firestore.collection('FinancialAdvisors').doc(advisorId).get();

      if (advisorDoc.exists) {
        String userId = advisorDoc['userID'].id;
        await _firestore
            .collection('FinancialAdvisors')
            .doc(advisorId)
            .delete();

        await _firestore.collection('Users').doc(userId).delete();

        await ImageHelper.deleteFolderFromStorage('users/$userId');
      } else {
        print('Financial Advisor does not exist.');
      }
    } catch (e) {
      print('Error delete financial advisor: $e');
    }
  }

  Future<void> createFinancialAdvisor(FinancialAdvisor advisor) async {
    try {
      DocumentReference userRef =
          _firestore.collection('Users').doc(advisor.user.id);

      await _firestore.collection('FinancialAdvisors').add({
        'userID': userRef,
        'isVerified': advisor.isVerified,
        'rejectReason': advisor.rejectReason,
        'icImageFront': advisor.icImageFront,
        'icImageBack': advisor.icImageBack,
      });
    } catch (e) {
      throw Exception('Failed to create financial advisor');
    }
  }

  Future<void> updateFinancialAdvisor(FinancialAdvisor advisor) async {
    try {
      // Update the Financial Advisor document
      await _firestore.collection('FinancialAdvisors').doc(advisor.id).update({
        'isVerified': advisor.isVerified,
        'rejectReason': advisor.rejectReason,
        'icImageFront': advisor.icImageFront,
        'icImageBack': advisor.icImageBack,
        // Add any other fields that need updating
      });

      // Update the User document associated with the advisor
      await _firestore.collection('Users').doc(advisor.user.id).update({
        'name': advisor.user.name,
        'email': advisor.user.email,
        'phoneNumber': advisor.user.phoneNumber,
        'occupation': advisor.user.occupation,
        'age': advisor.user.age,
        'imagePath': advisor.user.imagePath,
        // Address fields
        'address': {
          'unit': advisor.user.address.unit,
          'street': advisor.user.address.street,
          'city': advisor.user.address.city,
          'postalCode': advisor.user.address.postalCode,
          'state': advisor.user.address.state,
        },
        'isBan': advisor.user.isBan,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error updating financial advisor: $e');
    }
  }
}
