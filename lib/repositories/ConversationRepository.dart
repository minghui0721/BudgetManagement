import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/Conversation.dart';

class ConversationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Conversation>> fetchConversations(
      String faId, String userId) async {
    List<Conversation> conversations = [];

    try {
      QuerySnapshot conversationSnapshot = await _firestore
          .collection('Conversations')
          .where('faID',
              isEqualTo: _firestore.collection('FinancialAdvisors').doc(faId))
          .where('userID',
              isEqualTo: _firestore.collection('Users').doc(userId))
          .get();

      for (QueryDocumentSnapshot conversationDoc in conversationSnapshot.docs) {
        // Use fromFirestore
        Conversation conversation = Conversation.fromFirestore(conversationDoc);
        conversations.add(conversation);
      }
    } catch (e) {
      print('Error fetching conversations: $e');
    }

    return conversations;
  }

  Future<List<Conversation>> fetchConversationsById({
    String? faId,
    String? userId,
    required bool isReturnToUser,
  }) async {
    List<Conversation> conversations = [];

    try {
      QuerySnapshot conversationSnapshot;

      // Apply the relevant filter based on `isReturnToUser` and whether `faId` or `userId` is provided
      if (isReturnToUser && userId != null) {
        conversationSnapshot = await _firestore
            .collection('Conversations')
            .where('userID',
                isEqualTo: _firestore.collection('Users').doc(userId))
            .get();
      } else if (!isReturnToUser && faId != null) {
        conversationSnapshot = await _firestore
            .collection('Conversations')
            .where('faID',
                isEqualTo: _firestore.collection('FinancialAdvisors').doc(faId))
            .get();
      } else {
        print(
            'Error: Either faId or userId must be provided based on isReturnToUser.');
        return conversations;
      }

      for (QueryDocumentSnapshot conversationDoc in conversationSnapshot.docs) {
        Conversation conversation = Conversation.fromFirestore(conversationDoc);
        conversations.add(conversation);
      }
    } catch (e) {
      print('Error fetching conversations: $e');
    }

    return conversations;
  }

  Future<List<String>> fetchAssociatedIds({
    String? faId, // Optional
    String? userId, // Optional
    required bool returnFaList,
  }) async {
    List<String> associatedIds = [];

    try {
      // Ensure either faId or userId is provided
      if (faId == null && userId == null) {
        throw ArgumentError('Either faId or userId must be provided.');
      }

      // Declare query as type Query instead of CollectionReference
      Query<Map<String, dynamic>> query =
          _firestore.collection('Conversations');

      // Add the 'faID' condition if faId is provided
      if (faId != null) {
        query = query.where(
          'faID',
          isEqualTo: _firestore.collection('FinancialAdvisors').doc(faId),
        );
      }

      // Add the 'userID' condition if userId is provided
      if (userId != null) {
        query = query.where(
          'userID',
          isEqualTo: _firestore.collection('Users').doc(userId),
        );
      }

      // Execute the query
      QuerySnapshot conversationSnapshot = await query.get();

      // Process the query results
      for (QueryDocumentSnapshot conversationDoc in conversationSnapshot.docs) {
        if (returnFaList && faId == null) {
          // If returnFaList is true and we queried by userId, return faIDs
          String associatedFaId =
              (conversationDoc.data() as Map<String, dynamic>)['faID'].id;
          if (!associatedIds.contains(associatedFaId)) {
            associatedIds.add(associatedFaId);
          }
        } else if (!returnFaList && userId == null) {
          // If returnFaList is false and we queried by faId, return userIDs
          String associatedUserId =
              (conversationDoc.data() as Map<String, dynamic>)['userID'].id;
          if (!associatedIds.contains(associatedUserId)) {
            associatedIds.add(associatedUserId);
          }
        }
      }
    } catch (e) {
      print('Error fetching associated IDs: $e');
    }

    return associatedIds;
  }

  Future<Conversation?> findConversationByIds({
    required List<Conversation> conversations,
    required String userId,
    required String faId,
  }) async {
    // Simulating a delay, e.g., fetching data from a database
    await Future.delayed(Duration(milliseconds: 100));

    for (var conversation in conversations) {
      if (conversation.userId == userId && conversation.faId == faId) {
        return conversation;
      }
      return null;
    }
    return null;
  }
}
