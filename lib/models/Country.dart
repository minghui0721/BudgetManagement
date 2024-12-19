import 'package:cloud_firestore/cloud_firestore.dart';

class Country {
  final String name;
  final List<StateCities> states;

  Country({required this.name, required this.states});

  // Create a Country instance from a Firestore document snapshot
  factory Country.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Country(
      name: snapshot.id, // Assuming the document ID represents the country name, e.g., "Malaysia"
      states: data.entries.map((entry) {
        return StateCities(
          stateName: entry.key,
          cities: List<String>.from(entry.value),
        );
      }).toList(),
    );
  }

}

class StateCities {
  final String stateName;
  final List<String> cities;

  StateCities({required this.stateName, required this.cities});
}
