import 'package:flutter/material.dart';

class MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}