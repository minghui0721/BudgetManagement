import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wise/config/colors.dart'; // Import flutter_svg package

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
        enableFeedback: false, // Disable feedback like sounds
        showSelectedLabels: false, // Remove the space for the selected labels
        showUnselectedLabels: false, // Remove the space for the unselected labels
        items: [
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/admin-home1.svg', // Path to your SVG file
            isSelected: currentIndex == 0,
          ),
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/admin-system.svg', // Path to your SVG file
            isSelected: currentIndex == 1,
          ),
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/financial-advisor-request.svg', // Path to your SVG file
            isSelected: currentIndex == 2,
            isHighlighted: true,
          ),
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/financial-advisor-rp.svg', // Path to your SVG file
            isSelected: currentIndex == 3,
          ),
          _buildBottomNavItem(
            svgPath: 'assets/images/svg/admin-profile2.svg', // Path to your SVG file
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
                      color: AppColors.primary.withOpacity(0.6), // Glow effect color
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: SvgPicture.asset(
            svgPath, // Use the SVG picture instead of an icon
            width: isHighlighted ? 40 : 28, // Size for the highlighted middle button
            color: isSelected ? AppColors.primary : Colors.white,
          ),
        ),
      ),
      label: '', // No label as per your design
    );
  }
}
