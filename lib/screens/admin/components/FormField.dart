import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';

class AdminTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Icon? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isEnabled; // Add this parameter
  final bool obscureText; // Add obscureText parameter
  final Widget? suffixIcon; // Add suffixIcon parameter
  final ValueChanged<String>? onChanged; // Add onChanged parameter
  final int? minLines; // Add minLines parameter
  final int? maxLines; // Add maxLines parameter
  const AdminTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.isEnabled = true,
    this.obscureText = false, // Default to false (not obscured)
    this.suffixIcon, // Optional suffix icon (null by default)
    this.onChanged, // Optional onChanged callback
        this.minLines, // Add minLines parameter
    this.maxLines, // Add maxLines parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled, // Control whether the field is enabled or disabled
      obscureText: obscureText, // Obscure text based on the value
      minLines: obscureText ? 1 : (minLines ?? 1), // Ensure single line if obscured
      maxLines: obscureText ? 1 : maxLines, // Ensure single line if obscured
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.white, // Adjust color based on isEnabled
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor:  AppColors.lightGray,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon!.icon,
                color: AppColors.primary, // Adjust icon color based on isEnabled
                size: 20,
              )
            : null,
        suffixIcon: suffixIcon, // Use the passed suffix icon (if any)
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 20.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            color: isEnabled
                ? AppColors.gray
                : AppColors
                    .mediumGray,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            color: AppColors.darkRed,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: AppColors.red, width: 2.0),
        ),
      ),
      style: const TextStyle(
        color:  AppColors.primary,
        fontSize: 16,
      ),
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged, // Add the onChanged callback
    );
  }
}
