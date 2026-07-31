import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color_tokens.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // ── Shared accent / brand colours ─────────────────────────────────────────
  static const Color _primary = AppColors.primary;
  static const Color _secondary = AppColors.secondary;

  // ── Dark palette ──────────────────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF0F172A);           // Obsidian
  static const Color _darkSurface = Color(0xFF1E293B);      // Deep Slate
  static const Color _darkOnBg = Color(0xFFF1F5F9);         // Frost white text
  static const Color _darkOnSurface = Color(0xFFF1F5F9);
  static const Color _darkBorder = Color(0xFF334155);       // Slate-600

  // ── Light Theme ───────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.openSans().fontFamily,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundWhite,
    primaryColor: _primary,

    colorScheme: const ColorScheme.light(
      primary: _primary,
      secondary: _secondary,
      surface: AppColors.surfaceWhite,
      error: Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textBlack,
    ),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.buttonText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textBlack),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFF0F0F0),
      thickness: 1,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundWhite,
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.backgroundWhite,
    ),

    extensions: const <ThemeExtension<dynamic>>[
      AppColorTokens.light,
    ],
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.openSans().fontFamily,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBg,
    primaryColor: _primary,

    colorScheme: const ColorScheme.dark(
      primary: _primary,
      secondary: _secondary,
      surface: _darkSurface,
      error: Color(0xFFFF5252),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _darkOnSurface,
      onError: Colors.white,
    ),

    // Dark text theme — same structure, adjusted colors
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: _darkOnBg),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: _darkOnBg),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: _darkOnBg),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: _darkOnBg),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: _darkOnBg),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: _darkOnBg),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: _darkOnBg),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: _darkOnBg),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: _darkOnBg),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: _darkOnBg),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: _darkOnBg),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF94A3B8)),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: _darkOnBg),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: _darkOnBg),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF94A3B8)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF5252)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.buttonText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: _darkOnBg),
      titleTextStyle: TextStyle(
        color: _darkOnBg,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: _darkBorder,
      thickness: 1,
    ),

    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _darkBorder, width: 1),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: _darkSurface,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: _darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _darkBorder),
      ),
    ),

    extensions: const <ThemeExtension<dynamic>>[
      AppColorTokens.dark,
    ],
  );
}
