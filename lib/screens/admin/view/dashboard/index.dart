import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/view/dashboard/partials/ProfileSection.dart';
import 'package:wise/screens/admin/view/dashboard/partials/QuickAccessSection.dart';
import 'package:wise/screens/user/home/notification.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminAppBar(
          isDashboard: true,
          button: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.lightGray,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(Icons.notifications, color: Colors.white),
              ),
              const Positioned(
                right: 10,
                top: 9,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.red,
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.screenTopSpacing),
                ProfileSection(),
                const SizedBox(height: 24.0),
                QuickAccessSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
