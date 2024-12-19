import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';

class AppSizes {}

class AppTheme {
  static const dateFormat = "MMMM dd, yyyy";
  static const dateFormatWithTime = "MMMM dd, yyyy hh:mm a";
  static const title = 24.0;
  static const body = 14.0;

  DateTime now = DateTime.now();

  static const pageTitle = 28.0;

  static const headerSize = 20.0;
  static const headerSizeLg = 24.0;

  static const iconSizeSm = 20.0;
  static const iconSize = 24.0;
  static const iconSizeLg = 30.0;

  static const fontSizeSm = 12.0;
  static const fontSize = 14.0;
  static const fontSizeLg = 16.0;
  static const fontSizeXl = 18.0;
  static const fontSizeXxl = 20.0;

  static const containerPadding = 20.0;
  static const screenTopSpacing = 24.0;
  static const screenBottomSpacing = 10.0;
  static const listBottomSpacingAds = 100.0;
  static const listBottomSpacing = 70.0;

  static const gap = 10.0;
  static const paddingX = 12.0;

  static const spacingSm = 10.0;
  static const spacing = 15.0;
  static const spacingLg = 20.0;
  static const spacingXl = 25.0;
  static const spacingXxl = 30.0;
  static const spacingSection = 40.0;

  static const borderRadius = 8.0;
  static const borderRadiusLg = 10.0;
  static const borderRadiusXl = 15.0;

  static const borderWidth = 2.0;

  static const tagButtonHeightSm = 35.0;
  static const tagButtonHeight = 42.0;

  static const titleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const smallTitleStyle = TextStyle(
    color: Colors.grey,
    fontSize: 14.0,
  );

  static const dateTimeStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
}
