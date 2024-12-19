import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/providers/UserProvider.dart';
import 'package:wise/screens/admin/financial-advisor/index.dart';
import 'package:wise/screens/admin/user/index.dart';

class QuickAccessSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final financialAdvisorProvider =
        Provider.of<FinancialAdvisorProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 23.0,
        horizontal: AppTheme.paddingX,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildQuickAccessCard(
            title: financialAdvisorProvider.total.toString(),
            subtitle: 'Financial Advisors',
            icon: Icons.person_pin_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinancialAdvisorsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16.0),
          _buildQuickAccessCard(
            title: userProvider.total.toString(),
            subtitle: 'Users',
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            Icon(
              icon,
              size: 40.0,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
