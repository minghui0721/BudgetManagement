import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';

class TableCard extends StatelessWidget {
  final String imagePath;
  final Widget title;
  final List<Widget> details;
  final Function? onDelete;
  final Function? onEdit;
  final Function onView;

  final bool hasImage;
  final String placeholderImage;

  const TableCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.details,
    this.onDelete,
    this.onEdit,
    required this.onView,
    this.hasImage = true,
    this.placeholderImage = 'assets/images/Image-not-found.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppColors.lightGray,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            if (hasImage)
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imagePath),
                onBackgroundImageError: (exception, stackTrace) {
                  Image.asset(
                    placeholderImage,
                    fit: BoxFit.contain,
                  );
                },
              ),
            if (hasImage) const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    child: title,
                  ),
                  const SizedBox(height: 5),
                  ...details.map((detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            color: AppColors.lightTextGray,
                          ),
                          child: detail,
                        ),
                      )),
                ],
              ),
            ),
            Column(
              children: [
                if (onEdit != null) // Show edit icon only if onEdit is provided
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    iconSize: 23,
                    onPressed: () => onEdit!(),
                  ),
                if (onView != null) // Show view icon only if onView is provided
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.white),
                    iconSize: 23,
                    onPressed: () => onView(),
                  ),
                if (onDelete !=
                    null) // Show delete icon only if onDelete is provided
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    iconSize: 23,
                    onPressed: () => onDelete!(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
