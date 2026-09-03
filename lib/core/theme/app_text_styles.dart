import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 34,
    fontWeight: FontWeight.bold,
  );
  static const body = TextStyle(color: AppColors.textPrimary, fontSize: 16);
  static const secondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
  );
  static const tab = TextStyle(fontSize: 10);
}
