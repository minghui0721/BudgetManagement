import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wise/models/FinancialAdvisor.dart';
import 'package:wise/models/User.dart';
import 'package:wise/repositories/FinancialAdvisorRepository.dart';

enum RequestStatus { pending, approved, rejected, none }

class FinancialAdvisorProvider with ChangeNotifier {
  List<FinancialAdvisor> _advisors = [];
  int _total = 0;
  int _verified = 0;
  int _unverified = 0;
  bool _isLoading = true;
  String? _errorMessage;

  String? _advisorId;
  String? _advisorName;
  String? _advisorImagePath; // Define advisor image path here
    String? _occupation; // New field for occupation
  String? _email; // New field for email
  String? _phoneNumber; // New field for phone number
  int? _age;

  String? get advisorId => _advisorId;
  String? get advisorName => _advisorName;
  String? get advisorImagePath =>
      _advisorImagePath; // Add a getter for image path
  String? get occupation => _occupation;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  int? get age => _age; // Getter for age

  List<FinancialAdvisor> get advisors => _advisors;
  int get total => _total;
  int get verified => _verified;
  int get unverified => _unverified;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final FinancialAdvisorRepository _advisorRepo = FinancialAdvisorRepository();
  get approvedRequests => null;

  Future<void> fetchAllFinancialAdvisors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch advisors without counting logic in the repository
      List<FinancialAdvisor> advisors =
          await _advisorRepo.fetchAllFinancialAdvisors();

      // Perform the counting logic in the provider
      _total = advisors.length;
      _verified = advisors.where((advisor) => advisor.isVerified).length;
      _unverified = advisors.where((advisor) => !advisor.isVerified).length;

      _advisors = advisors;
    } catch (e) {
      _errorMessage = 'Error fetching data: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add the addRequest method
  Future<void> addRequest(
      String advisorId, String userId, String message) async {
    try {
      final requestRef = FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .doc(advisorId)
          .collection('Request')
          .doc(); // Creates a new document with an auto-generated ID

      await requestRef.set({
        'Status': 'Pending', // Initial status
        'additionalComment': message, // User's message
        'submitRequestTime': FieldValue.serverTimestamp(),
        'userID': userId,
      });

      // Optionally, notify listeners if this action affects other parts of the UI
      notifyListeners();
    } catch (e) {
      print("Error adding request: $e");
      _errorMessage = 'Error adding request: $e';
      notifyListeners();
    }
  }

  Future<void> fetchAdvisorIdByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('Request')
          .where('userID',
              isEqualTo:
                  FirebaseFirestore.instance.collection('Users').doc(userId))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot requestDoc = querySnapshot.docs.first;
        _advisorId = requestDoc.reference.parent.parent?.id;

        if (_advisorId != null) {
          DocumentSnapshot advisorDoc = await FirebaseFirestore.instance
              .collection('FinancialAdvisors')
              .doc(_advisorId)
              .get();

          DocumentReference userRef = advisorDoc['userID'];
          DocumentSnapshot userDoc = await userRef.get();

          _advisorName = userDoc['name'];
          _advisorImagePath = userDoc['imagePath'];
          _occupation = userDoc['occupation'];
          _email = userDoc['email'];
          _phoneNumber = userDoc['phoneNumber'];
          _age = userDoc['age']; // Retrieve age from user document
        } else {
          _advisorName = null;
          _advisorImagePath = null;
          _occupation = null;
          _email = null;
          _phoneNumber = null;
          _age = null; // Reset age if no advisor ID found
        }
      } else {
        _advisorId = null;
        _advisorName = null;
        _advisorImagePath = null;
        _occupation = null;
        _email = null;
        _phoneNumber = null;
        _age = null; // Reset age if no advisor ID found
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching advisorId and advisor details by userId: $e");
    }
  }

  Future<String> getRejectionReason(String advisorId, String userId) async {
    try {
      // Create a reference to the request document
      DocumentSnapshot requestDoc = await FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .doc(advisorId)
          .collection('Request')
          .where('userID',
              isEqualTo:
                  FirebaseFirestore.instance.collection('Users').doc(userId))
          .where('Status', isEqualTo: 'Rejected')
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      // Retrieve and return the rejection reason from the document
      return requestDoc['RejectionReason'] ?? "No reason provided";
    } catch (e) {
      print("Error retrieving rejection reason: $e");
      return "Error retrieving rejection reason.";
    }
  }

  Future<List<User>> fetchApprovedRequests(String faId) async {
    print(faId);
    List<User> approvedUsers = [];
    try {
      // Step 1: Find the document in the FinancialAdvisors collection where userID equals faId
      QuerySnapshot advisorSnapshot = await FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .where('userID',
              isEqualTo:
                  FirebaseFirestore.instance.collection('Users').doc(faId))
          .get();

      if (advisorSnapshot.docs.isNotEmpty) {
        // Get the ID of the found document
        String advisorDocId = advisorSnapshot.docs.first.id;
        print("Found financial advisor document ID: $advisorDocId");

        // Step 2: Fetch approved requests in the Request sub-collection of the found document
        QuerySnapshot approvedRequestsSnapshot = await FirebaseFirestore
            .instance
            .collection('FinancialAdvisors')
            .doc(advisorDocId)
            .collection('Request')
            .where('Status', isEqualTo: 'Approved')
            .get();

        if (approvedRequestsSnapshot.docs.isEmpty) {
          print("No approved requests found in the Request sub-collection.");
        } else {
          for (var doc in approvedRequestsSnapshot.docs) {
            DocumentReference userRef = doc['userID'];
            print("Found approved request with userRef: ${userRef.id}");

            // Fetch the user document using the user reference
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(userRef.id)
                .get();

            if (userDoc.exists) {
              print("User document found for userId: ${userDoc.id}");
              approvedUsers.add(User.fromDocument(userDoc));
            } else {
              print("User document not found for userId: ${userRef.id}");
            }
          }
        }
      } else {
        print("No financial advisor document found with userID matching faId.");
      }
    } catch (e) {
      print("Error fetching approved requests: $e");
    }

    return approvedUsers;
  }

  Future<List<Map<String, dynamic>>> fetchPendingRequests(String faId) async {
    List<Map<String, dynamic>> pendingUsersWithIds = [];
    try {
      // Step 1: Find the document in the FinancialAdvisors collection where userID equals faId
      QuerySnapshot advisorSnapshot = await FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .where('userID',
              isEqualTo:
                  FirebaseFirestore.instance.collection('Users').doc(faId))
          .get();

      if (advisorSnapshot.docs.isNotEmpty) {
        // Get the ID of the found document
        String advisorDocId = advisorSnapshot.docs.first.id;
        print("Found financial advisor document ID: $advisorDocId");

        // Step 2: Fetch pending requests in the Request sub-collection of the found document
        QuerySnapshot pendingRequestsSnapshot = await FirebaseFirestore.instance
            .collection('FinancialAdvisors')
            .doc(advisorDocId)
            .collection('Request')
            .where('Status', isEqualTo: 'Pending')
            .get();

        if (pendingRequestsSnapshot.docs.isNotEmpty) {
          for (var doc in pendingRequestsSnapshot.docs) {
            DocumentReference userRef = doc['userID'];
            print("Found pending request with userRef: ${userRef.id}");

            // Fetch the user document using the user reference
            DocumentSnapshot userDoc = await userRef.get();

            if (userDoc.exists) {
              print("User document found for userId: ${userDoc.id}");
              User user = User.fromDocument(userDoc);

              // Create a map that includes the user and the request ID
              pendingUsersWithIds.add({
                'user': user,
                'requestId': doc.id,
              });
            } else {
              print("User document not found for userId: ${userRef.id}");
            }
          }
        } else {
          print("No pending requests found in the Request sub-collection.");
        }
      } else {
        print("No financial advisor document found with userID matching faId.");
      }
    } catch (e) {
      print("Error fetching pending requests: $e");
    }

    return pendingUsersWithIds;
  }

  Future<User?> fetchRequestDetails(String requestId, String userId) async {
    try {
      if (requestId.isEmpty) {
        throw Exception("Request ID is empty");
      }

      // Step 1: Find the document in the FinancialAdvisors collection where userID equals userId
      QuerySnapshot advisorSnapshot = await FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .where('userID',
              isEqualTo:
                  FirebaseFirestore.instance.collection('Users').doc(userId))
          .get();

      if (advisorSnapshot.docs.isNotEmpty) {
        // Get the ID of the found document
        String advisorDocId = advisorSnapshot.docs.first.id;
        print("Found financial advisor document ID: $advisorDocId");

        // Step 2: Use the found advisor ID to access the Request sub-collection
        DocumentSnapshot requestSnapshot = await FirebaseFirestore.instance
            .collection('FinancialAdvisors')
            .doc(advisorDocId)
            .collection('Request')
            .doc(requestId)
            .get();

        if (requestSnapshot.exists) {
          // Extract the additionalComment from the request document
          String additionalComment = requestSnapshot['additionalComment'] ??
              'No additional comment provided.';

          // Get the user reference and document
          DocumentReference userRef = requestSnapshot['userID'];
          DocumentSnapshot userSnapshot = await userRef.get();
          if (userSnapshot.exists) {
            User user = User.fromDocument(userSnapshot);
            user.additionalComment =
                additionalComment; // Set the additionalComment in the User object
            return user;
          }
        }
      } else {
        print(
            "No financial advisor document found with userID matching $userId.");
      }
    } catch (e) {
      print("Error fetching request details: $e");
    }
    return null;
  }

  Future<String?> getAdvisorIdByUserId(String userId) async {
    try {
      QuerySnapshot advisorSnapshot = await FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .where('userID',
              isEqualTo:
                  FirebaseFirestore.instance.collection('Users').doc(userId))
          .get();

      if (advisorSnapshot.docs.isNotEmpty) {
        return advisorSnapshot.docs.first.id;
      } else {
        print(
            "No financial advisor document found with userID matching $userId.");
      }
    } catch (e) {
      print("Error fetching advisor ID: $e");
    }
    return null;
  }

  Future<bool> updateRequestStatus(BuildContext context, String advisorId,
      String requestId, String status) async {
    try {
      final requestRef = FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .doc(advisorId)
          .collection('Request')
          .doc(requestId);

      final requestSnapshot = await requestRef.get();
      if (requestSnapshot.exists) {
        await requestRef.update({'Status': status});
        return true; // Indicate success
      }
    } catch (e) {
      print('Error updating request status: $e');
    }
    return false; // Indicate failure
  }

  Future<RequestStatus> checkRequestStatus(
      String advisorId, String userId) async {
    try {
      // Create a DocumentReference for the userID in the Users collection
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Get the request document for the user under the specified advisor
      QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .doc(advisorId)
          .collection('Request')
          .where('userID', isEqualTo: userRef)
          .limit(1) // We only need to check if at least one document exists
          .get();

      // Check the document status if any matching document is found
      if (requestSnapshot.docs.isNotEmpty) {
        var status = requestSnapshot.docs.first.get('Status');
        if (status == 'Pending') return RequestStatus.pending;
        if (status == 'Approved') return RequestStatus.approved;
        if (status == 'Rejected') return RequestStatus.rejected;
      }
    } catch (e) {
      print("Error checking request status: $e");
      _errorMessage = 'Error checking request status: $e';
      notifyListeners();
    }
    return RequestStatus.none;
  }
}
