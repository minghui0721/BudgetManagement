import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDashboard;
  final String title;
  final bool showBackButton;
  final Widget? button;
  final Function? onPressed;

  const AdminAppBar({
    Key? key,
    this.isDashboard = false,
    this.title = '',
    this.showBackButton = false,
    this.button,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: isDashboard
          ? Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Image.asset(
                    'assets/images/logo/noWord.png',
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
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : null,
      actions: [
        if (button != null)
          IconButton(
            icon: button!,
            onPressed: onPressed != null ? () => onPressed!() : null,
            color: Colors.white,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
