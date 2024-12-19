import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/MenuCard.dart';
import 'package:wise/screens/admin/notification/index.dart';

class AdminCreate extends StatelessWidget {
  const AdminCreate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: const AdminAppBar(
        title: 'Content',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingX),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.screenTopSpacing),
              MenuCard(
                imagePath: 'assets/admin/notification.jpeg',
                title: 'Notification',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(),
                    ),
                  );
                },
              ),
              MenuCard(
                imagePath: 'assets/admin/report.jpg',
                title: 'Report',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
