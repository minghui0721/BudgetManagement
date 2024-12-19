import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String occupation;
  final int age;
  final bool isBan;
  final Address address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imagePath;
    String? additionalComment; // New property
  final String? requestId; // New property

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.occupation,
    required this.age,
    required this.isBan,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.imagePath,
        this.additionalComment, // New parameter
    this.requestId, // New parameter
  });


    // Factory method to create a User instance from a Firestore document
  factory User.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      password: data['password'] ?? '',
      occupation: data['occupation'] ?? '',
      age: data['age'] ?? 0,
      isBan: data['isBan'] ?? false,
      address: Address.fromJson(data['address'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imagePath: data['imagePath'] ?? '',
      additionalComment: data['additionalComment'], // Fetch from Firestore
      requestId: data['requestId'], // Fetch from Firestore
    );
  }


  factory User.fromJson(Map<String, dynamic> json, String id) {
    return User(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'],
      occupation: json['occupation'],
      age: json['age'] ?? '',
      isBan: json['isBan'] ?? 'false',
      address: Address.fromJson(json['address'] ?? {}),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imagePath: json['imagePath'] ?? '',
    );
  }
}

class Address {
  final String unit;
  final String street;
  final String city;
  final String postalCode;
  final String state;

  Address({
    required this.unit,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      unit: json['unit'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      state: json['state'] ?? '',
    );
  }
}
