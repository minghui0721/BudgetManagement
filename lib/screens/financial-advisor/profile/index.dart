// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wise/screens/financial-advisor/components/AppBar.dart';
// import 'package:wise/screens/financial-advisor/profile/partial/edit-profile.dart';
// import 'package:wise/screens/financial-advisor/profile/partial/view-member/brief-members.dart';
// import 'package:wise/screens/user/User.dart';
// import 'package:wise/providers/UserProvider.dart';

// class FinancialAdvisorProfile extends StatelessWidget {
//   const FinancialAdvisorProfile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);
    
//     return Scaffold(
//       body: Column(
//         children: [
//           const CustomAppBar(isDashboard: false, title: 'Profile'),
//           Expanded(
//             child: userProvider.isCurrentUserLoading 
//               ? const Center(child: CircularProgressIndicator()) 
//               : _buildUserProfile(context, userProvider),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserProfile(BuildContext context, UserProvider userProvider) {
//     if (userProvider.errorMessage != null) {
//       return Center(
//         child: Text(
//           userProvider.errorMessage!,
//           style: const TextStyle(color: Colors.red, fontSize: 16),
//         ),
//       );
//     }

//     final currentUser = userProvider.currentUser;
//     if (currentUser == null) {
//       return const Center(child: Text('User data not found'));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Profile Details
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade800,
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30.0,
//                   backgroundImage: currentUser.imagePath.isNotEmpty
//                       ? NetworkImage(currentUser.imagePath)
//                       : NetworkImage(currentUser.defaultImagePath),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       currentUser.fullName,
//                       style: const TextStyle(
//                         fontSize: 16.0,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4.0),
//                     Text(
//                       currentUser.phoneNumber.isEmpty
//                           ? 'Phone number not set'
//                           : currentUser.phoneNumber,
//                       style: const TextStyle(
//                         fontSize: 14.0,
//                         color: Colors.white54,
//                       ),
//                     ),
//                     Text(
//                       currentUser.email,
//                       style: const TextStyle(
//                         fontSize: 14.0,
//                         color: Colors.white54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24.0),

//           // Profile Options
//           _buildProfileOption(
//             context,
//             icon: Icons.person,
//             label: 'Edit Profile',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const EditProfilePage()),
//               );
//             },
//           ),
//           _buildProfileOption(
//             context,
//             icon: Icons.group,
//             label: 'Members',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => BriefMembersPage(faId: currentUser.id)),
//               );
//             },
//           ),
//           _buildProfileOption(
//             context,
//             icon: Icons.account_box,
//             label: userProvider.isFinancialAdvisor
//                 ? 'Switch to User Account'
//                 : 'Become Financial Advisor',
//             onTap: () => _showChangeRoleBottomSheet(context),
//           ),
//           _buildProfileOption(
//             context,
//             icon: Icons.logout,
//             label: 'Logout',
//             onTap: () {
//               // Implement logout functionality here
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileOption(BuildContext context, {required IconData icon, required String label, required Function() onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12.0),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 24.0,
//               backgroundColor: Colors.black,
//               child: Icon(icon, size: 24.0, color: Colors.amber),
//             ),
//             const SizedBox(width: 16.0),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showChangeRoleBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
//       ),
//       builder: (BuildContext context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Change Role',
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16.0),
//               const Text('Are you sure you want to change your role to User?'),
//               const SizedBox(height: 24.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
//                     child: const Text('No', style: TextStyle(color: Colors.white)),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       Provider.of<UserProvider>(context, listen: false).toggleRole();
//                       Navigator.pop(context);
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => const UserScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
//                     child: const Text('Yes', style: TextStyle(color: Colors.black)),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/financial-advisor/components/AppBar.dart';
import 'package:wise/screens/financial-advisor/profile/partial/edit-profile.dart';
import 'package:wise/screens/financial-advisor/profile/partial/view-member/brief-members.dart';
import 'package:wise/screens/user/login/login.dart';
import 'package:wise/screens/user/rootPage.dart';

class FinancialAdvisorProfile extends StatefulWidget {
  const FinancialAdvisorProfile({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<FinancialAdvisorProfile> {
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(isDashboard: false, title: 'Profile'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Details
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                UserData().fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                UserData().phoneNumber.isEmpty
                                    ? 'Phone number not set'
                                    : UserData().phoneNumber,
                                style: const TextStyle(
                                  color: Color(0xFFF8E4B2),
                                  fontSize: 14.0,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                UserData().email,
                                style: const TextStyle(
                                  color: Color(0xFFF8E4B2),
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                          // Profile Image
                          CircleAvatar(
                            radius: 30.0,
                            backgroundImage: UserData().imagePath.isNotEmpty
                                ? NetworkImage(UserData().imagePath)
                                : NetworkImage(UserData().defaultImagePath),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    // Options List
                    _buildOptionItem(
                      context,
                      Icons.person,
                      'Edit Profile',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfilePage()),
                        );
                      },
                    ),
                    _buildOptionItem(
                      context,
                      Icons.category,
                      'Members',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BriefMembersPage(faId: UserData().uid)),
                        );
                      },
                    ),
                    _buildOptionItem(
                      context,
                      Icons.account_box,
                      'Switch to User Account',
                      () {
                        _showChangeRoleBottomSheet(context);
                      },
                    ),
                    _buildOptionItem(
                      context,
                      Icons.logout,
                      'Logout',
                      () {
                        _confirmLogout(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16.0),
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 20.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text(
            "Confirm Logout",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Logout", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _logoutUser(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _logoutUser(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _showChangeRoleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Role',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              const Text('Are you sure you want to change your role to User?'),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('No', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => RootPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: const Text('Yes', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}





