import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/screens/financial-advisor/dashboard/partials/notifications.dart'; // Import the notifications page

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDashboard;
  final String title;

  const CustomAppBar({
    super.key,
    required this.isDashboard,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false, // Removes the default back button
      centerTitle: true,
      title: isDashboard
          ? Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Image.asset(
                    'assets/images/logo/noWord.png', // Your logo asset
                    height: 60,
                  ),
                ),
                const Text(
                  'WISE',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
      actions: isDashboard
          ? [
              IconButton(
                icon: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.lightGray, // Light gray background
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8.0), // Padding for background circle
                      child: const Icon(Icons.notifications,
                          color: Colors.white), // Notification icon
                    ),
                    const Positioned(
                      right: 10,
                      top: 9,
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor:
                            AppColors.red, // Red notification indicator
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  // Navigate to the notifications page when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()), // Notification Page
                  );
                },
              ),
            ]
          : null, // No actions if not dashboard
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
