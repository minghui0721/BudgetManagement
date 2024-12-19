import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wise/config/theme.dart';

class ImageSection extends StatelessWidget {
  final String label;
  final File? imageFile;
  final TextEditingController controller;
  final VoidCallback onTap;

  const ImageSection({
    Key? key,
    required this.label,
    required this.imageFile,
    required this.controller,
    required this.onTap,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.titleTextStyle),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageFile != null
                    ? FileImage(imageFile!)
                    : NetworkImage(controller.text) as ImageProvider,
                fit: BoxFit.cover,
              ),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
