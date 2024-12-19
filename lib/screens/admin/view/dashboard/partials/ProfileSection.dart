import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/providers/userGlobalVariables.dart';

class ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.lightGray,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Picture with border
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              radius: 40.0,
              backgroundImage: UserData().imagePath.isNotEmpty
                  ? NetworkImage(UserData().imagePath)
                  : NetworkImage(UserData().defaultImagePath),
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Welcome Back!',
            style: AppTheme.titleTextStyle,
          ),
          Text(
            UserData().fullName,
            style: AppTheme.titleTextStyle,
          ),
        ],
      ),
    );
  }
}
