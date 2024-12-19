import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/screens/admin/bank/index.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/MenuCard.dart';
import 'package:wise/screens/admin/spending-category/index.dart';
import 'package:wise/screens/admin/term-condition/index.dart';

class AdminContent extends StatelessWidget {
  const AdminContent({super.key});

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
                imagePath: 'assets/admin/category.jpeg',
                title: 'Category',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpendingCategoriesScreen(),
                    ),
                  );
                },
              ),
              MenuCard(
                imagePath: 'assets/admin/bank.png',
                title: 'Partner Bank',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BanksScreen(),
                    ),
                  );
                },
              ),
              MenuCard(
                imagePath: 'assets/admin/tac.png',
                title: 'Terms & Conditions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TacsScreen(),
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
