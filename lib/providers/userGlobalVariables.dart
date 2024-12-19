import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  static final UserData _instance = UserData._internal();

  String uid = '';
  String fullName = '';
  String email = '';
  String imagePath = '';
  String defaultImagePath =
      'https://firebasestorage.googleapis.com/v0/b/wise-6b980.appspot.com/o/userNotFound.jpg?alt=media&token=de7af84c-f7ef-4c0d-854a-5471cbb9123f';
  String phoneNumber = '';
  String occupation = '';
  String city = '';
  String postalCode = '';
  String state = '';
  String street = '';
  String unit = '';
  bool isBan = false;
  int age = 0;

  factory UserData() {
    return _instance;
  }

  UserData._internal();

  void retrieveLoginUser(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      // Set user details globally
      setUserDetails(
        uid: uid,
        fullName: userDoc['name'],
        email: userDoc['email'],
        imagePath: userDoc['imagePath'],
        phoneNumber: userDoc['phoneNumber'],
        occupation: userDoc['occupation'],
        city: userDoc['address']['city'],
        postalCode: userDoc['address']['postalCode'],
        state: userDoc['address']['state'],
        street: userDoc['address']['street'],
        unit: userDoc['address']['unit'],
        isBan: userDoc['isBan'],
        age: userDoc['age'],
      );
    } catch (e) {
      print("Error retrieving user data: $e");
      // Handle error accordingly
    }
  }

  // Add a method to set user data after login
  void setUserDetails({
    required String uid,
    required String fullName,
    required String email,
    String imagePath = '',
    String phoneNumber = '',
    String occupation = '',
    String city = '',
    String postalCode = '',
    String state = '',
    String street = '',
    String unit = '',
    bool isBan = false,
    int age = 0,
  }) {
    this.uid = uid;
    this.fullName = fullName;
    this.email = email;
    this.imagePath = imagePath;
    this.phoneNumber = phoneNumber;
    this.occupation = occupation;
    this.city = city;
    this.postalCode = postalCode;
    this.state = state;
    this.street = street;
    this.unit = unit;
    this.isBan = isBan;
    this.age = age;
  }
}
