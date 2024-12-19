import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/Goals.dart';

class GoalRepository {
  final CollectionReference goalsCollection =
      FirebaseFirestore.instance.collection('Goals');

  // Add a new goal with a user reference
  Future<void> addGoal(DocumentReference userRef, Goal goal) async {
    await goalsCollection.add(goal.toJson()..['userRef'] = userRef);
  }

Stream<List<Goal>> getGoals(DocumentReference userRef) async* {
  try {
    print("Querying goals for userRef: ${userRef.path}");

    var querySnapshot = await goalsCollection
        .where('userRef', isEqualTo: userRef)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("No documents found for userRef: ${userRef.path}");
      yield []; // Emit an empty list to indicate no data
    } else {
      print("Documents found: ${querySnapshot.docs.length} for userRef: ${userRef.path}");
      yield querySnapshot.docs.map((doc) {
        return Goal.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    }
  } catch (e) {
    print("Error retrieving goals for userRef ${userRef.path}: $e");
    yield []; // Emit an empty list in case of an error
  }
}


  // Update the current amount for a specific goal
  Future<void> updateGoalAmount(String goalId, double newAmount) async {
    await goalsCollection.doc(goalId).update({'currentAmount': newAmount});
  }

  Future<void> updateGoal(String userId, Goal goal) async {
    final goalDoc = FirebaseFirestore.instance
        .collection('Goals')
        .doc(goal.id); // Make sure to use the specific goal's ID here

    await goalDoc.update(goal.toJson());
  }

  // Delete a specific goal based on the goal ID
  Future<void> deleteGoal(String goalId) async {
    await goalsCollection.doc(goalId).delete();
  }

  Future<List<Goal>> getGoalsOnce(DocumentReference userRef) async {
    try {
      var querySnapshot = await goalsCollection
          .where('userRef', isEqualTo: userRef)
          .get();

      return querySnapshot.docs.map((doc) {
        return Goal.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error retrieving goals for userRef ${userRef.path}: $e");
      return [];
    }
  }
}