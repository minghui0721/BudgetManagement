// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wise/models/User.dart';
// import 'package:wise/repositories/UserRepository.dart';


// class UserScreen extends StatefulWidget {
//   @override
//   _UserScreenState createState() => _UserScreenState();
// }

// class _UserScreenState extends State<UserScreen> {
//   final UserRepository _repository = UserRepository();
//   List<User> _users = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//   }

//   Future<void> _fetchUsers() async {
//     try {
//       List<User> users = await _repository.getAllUsers();
//       setState(() {
//         _users = users;
//         _isLoading = false;
//       });
//     } catch (e) {
//       // Handle error
//       setState(() {
//         _isLoading = false;
//       });
//       print('Error fetching users: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Users'),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _users.length,
//               itemBuilder: (context, index) {
//                 User user = _users[index];
//                 return Card(
//                   margin: EdgeInsets.all(8.0),
//                   child: ListTile(
//                     leading: Image.asset(user.imagePath),
//                     title: Text(user.name),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Email: ${user.email}'),
//                         Text('Phone: ${user.phoneNumber}'),
//                         Text('Occupation: ${user.occupation}'),
//                         Text('Address: ${user.address.street}, ${user.address.city}, ${user.address.state}, ${user.address.postalCode}'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
