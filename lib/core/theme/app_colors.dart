import 'dart:ui';
import 'package:flutter/material.dart';

// --- Theme Colors (Light Mode) ---
class AppColors {
  // --- Main Brand Colors ---
  static const Color primary = Color(0xFF009688); // Teal (New Primary)
  static const Color secondary = Color(0xFF00A99D); // Teal Dark (Secondary/Dark Variant)
  static const Color brandYellow = Color(0xFFFFD428); // Legacy Brand Yellow (now Accent)
  static const Color brandYellowDark = Color(0xFFE6BE20);

  // --- Background & Surface ---
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color surfaceWhite = Color(0xFFFAFAFA); // Slightly off-white for inputs
  static const Color backgroundLightGrey = Color(0xFFF5F7F9);
  
  // --- Text Colors ---
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF424242);
  static const Color iconGrey = Color(0xFF9E9E9E);  

  // --- Borders & Dividers ---
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color borderGreyLight = Color(0xFFE0E0E0); // shade300 approx

  // --- Status Colors ---
  static const Color errorRed = Color(0xFFFF5252);
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFF6D00);
  
  // --- Legacy/Aliases (To prevent breaking changes immediately, mapping to new colors) ---
  static const Color primaryAccent = brandYellow; // Deprecated alias
  static const Color primaryAccentDark = brandYellowDark; // Deprecated alias
  static const Color primaryTeal = primary;
  static const Color primaryTealDark = secondary;
}