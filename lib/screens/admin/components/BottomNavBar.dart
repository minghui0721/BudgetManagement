import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wise/config/colors.dart'; // Import flutter_svg package

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        enableFeedback: false, 
        showSelectedLabels: false, 
        showUnselectedLabels: false, 
        items: [
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/admin-home1.svg', 
            isSelected: currentIndex == 0,
          ),
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/admin-content-right.svg', 
            isSelected: currentIndex == 1,
          ),
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/admin-add-square.svg', 
            isSelected: currentIndex == 2,
            isHighlighted: true,
          ),
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/admin-system.svg', 
            isSelected: currentIndex == 3,
          ),
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/admin-profile2.svg', 
            isSelected: currentIndex == 4,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required String svgPath,
    required bool isSelected,
    bool isHighlighted = false,
  }) {
    return BottomNavigationBarItem(
      icon: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.6), 
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: SvgPicture.asset(
            svgPath,
            width: isHighlighted ? 40 : 28, 
            color: isSelected ? AppColors.primary : Colors.white,
          ),
        ),
      ),
      label: '', 
    );
  }
}
