import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wise/models/Country.dart';

class CountryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<List<String>> getStates() async {
    try {
      // Access the 'country' collection and retrieve the 'Malaysia' document
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('Country').doc('Malaysia').get();
      print("here");
      // Check if the document exists and extract the state names
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          // Extract keys (state names) from the document
          List<String> states = data.keys.toList();

          // Print each state for debugging
          for (String state in states) {
            print("State: $state"); // Debug print
          }

          return states;
        }
      }
    } catch (e) {
      print("Error fetching states: $e");
    }

    return [];
  }



  // Fetch the list of cities for a specific state in a given country
  Future<List<String>> fetchCities(String country, String state) async {
    DocumentSnapshot<Map<String, dynamic>> countrySnapshot =
        await _firestore.collection('Country').doc(country).get();

    if (countrySnapshot.exists) {
      var data = countrySnapshot.data();
      if (data != null && data[state] != null) {
        return List<String>.from(data[state]);
      }
    }
    return [];
  }
}
