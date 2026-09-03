import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.pageBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentYellow,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
    ),
    dividerColor: AppColors.separator,
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.pageTitle,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.secondary,
    ),
  );
}
