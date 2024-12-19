import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/admin/details.dart';
import 'package:wise/screens/admin/components/ConfirmationDialog.dart';
import 'package:wise/screens/admin/components/MenuOption.dart';
import 'package:wise/screens/user/login/login.dart';

class AdminProfile extends StatelessWidget {
  const AdminProfile({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Logout",
          content: "Are you sure you want to log out?",
          confirmButtonText: "Yes",
          cancelButtonText: "No",
          onConfirm: () {
            Navigator.of(context).pop();
            _logoutUser(context);
          },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: const AdminAppBar(
        title: 'Profile',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingX),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.screenTopSpacing),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppColors.lightTextGray,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UserData().fullName,
                          style: AppTheme.titleTextStyle,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          UserData().phoneNumber,
                          style: AppTheme.smallTitleStyle,
                        ),
                        Text(
                          UserData().email,
                          style: AppTheme.smallTitleStyle,
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 32.0,
                    backgroundImage: UserData().imagePath.isNotEmpty
                        ? NetworkImage(UserData().imagePath)
                        : NetworkImage(UserData().defaultImagePath),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            MenuOption(
              icon: Icons.person,
              label: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminDetailsScreen(isCreateMode: false),
                  ),
                );
              },
            ),
            MenuOption(
              icon: Icons.admin_panel_settings,
              label: 'Add Admin',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminDetailsScreen(isCreateMode: true),
                  ),
                );
              },
            ),
            MenuOption(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {
                 _confirmLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
