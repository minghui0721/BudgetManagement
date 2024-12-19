import 'package:flutter/material.dart';

class WiseBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const WiseBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Color(0xFF0b0f12),
      selectedItemColor: Color(0xFFF8E4B2),
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.only(
                bottom: 0.0), // Adjust to extend into label space
            child: Icon(
              Icons.add_box,
              size: 32, // Increase the icon size to make it cover more space
            ),
          ),
          label: 'Add', // Keep label empty to provide full space to the icon
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
