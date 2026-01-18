
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Use Open Sans for the entire app
  static final TextStyle _baseStyle = GoogleFonts.openSans();

  // --- Headlines ---
  static TextStyle get displayLarge => _baseStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: AppColors.textBlack,
      );

  static TextStyle get displayMedium => _baseStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.textBlack,
      );

  static TextStyle get displaySmall => _baseStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.textBlack,
      );

  static TextStyle get headlineLarge => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.textBlack,
      );

  static TextStyle get headlineMedium => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.textBlack,
      );

  static TextStyle get headlineSmall => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.textBlack,
      );

  // --- Titles ---
  static TextStyle get titleLarge => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.textBlack,
      );

  static TextStyle get titleMedium => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: AppColors.textBlack,
      );

  static TextStyle get titleSmall => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.textBlack,
      );

  // --- Body ---
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0.5,
        color: AppColors.textBlack,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: AppColors.textBlack,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: AppColors.textGrey, // Lighter for small body text
      );

  // --- Labels (Buttons, Captions) ---
  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.textBlack,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textBlack,
      );

  static TextStyle get labelSmall => _baseStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textGrey,
      );

  // --- Custom Purpose Styles ---
  static TextStyle get buttonText => labelLarge.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black, // Buttons often on primary color
  );
  
  static TextStyle get linkText => bodyMedium.copyWith(
    color: AppColors.primaryAccentDark,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );
}
