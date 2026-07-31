import 'package:flutter/material.dart';

/// Custom color tokens embedded into ThemeData via ThemeExtension.
///
/// Access anywhere via:
///   final c = Theme.of(context).ext;
///   Container(color: c.surface)
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  // ── Backgrounds ───────────────────────────────────────────────────────────
  final Color scaffoldBg;
  final Color surface;       // card / bottom-sheet / dialog backgrounds
  final Color backgroundGrey; // page background behind cards
  final Color inputFill;     // TextField / search bar fill

  // ── Text ──────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary; // placeholders, disabled

  // ── Borders / Dividers ────────────────────────────────────────────────────
  final Color border;
  final Color borderLight;
  final Color divider;

  // ── Shadows ───────────────────────────────────────────────────────────────
  final Color shadow;
  final Color shadowLight;

  // ── Status (same across modes) ────────────────────────────────────────────
  final Color error;
  final Color success;
  final Color warning;

  const AppColorTokens({
    required this.scaffoldBg,
    required this.surface,
    required this.backgroundGrey,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderLight,
    required this.divider,
    required this.shadow,
    required this.shadowLight,
    required this.error,
    required this.success,
    required this.warning,
  });

  // ── Light tokens ──────────────────────────────────────────────────────────
  static const AppColorTokens light = AppColorTokens(
    scaffoldBg:     Color(0xFFFFFFFF),
    surface:        Color(0xFFFFFFFF),
    backgroundGrey: Color(0xFFF5F7F9),
    inputFill:      Color(0xFFFAFAFA),
    textPrimary:    Color(0xFF1A1A1A),
    textSecondary:  Color(0xFF424242),
    textTertiary:   Color(0xFF9E9E9E),
    border:         Color(0xFFE0E0E0),
    borderLight:    Color(0xFFEEEEEE),
    divider:        Color(0xFFF0F0F0),
    shadow:         Color(0x0F000000),   // ~6% black
    shadowLight:    Color(0x08000000),   // ~3% black
    error:          Color(0xFFFF5252),
    success:        Color(0xFF00C853),
    warning:        Color(0xFFFF6D00),
  );

  // ── Dark tokens ───────────────────────────────────────────────────────────
  static const AppColorTokens dark = AppColorTokens(
    scaffoldBg:     Color(0xFF0F172A),   // Obsidian
    surface:        Color(0xFF1E293B),   // Deep Slate
    backgroundGrey: Color(0xFF0F172A),   // same as scaffold
    inputFill:      Color(0xFF1E293B),
    textPrimary:    Color(0xFFF1F5F9),   // Frost white
    textSecondary:  Color(0xFF94A3B8),   // Slate 400
    textTertiary:   Color(0xFF64748B),   // Slate 500
    border:         Color(0xFF334155),   // Slate 700
    borderLight:    Color(0xFF1E293B),
    divider:        Color(0xFF334155),
    shadow:         Color(0x73000000),   // ~45% black
    shadowLight:    Color(0x40000000),   // ~25% black
    error:          Color(0xFFFF5252),
    success:        Color(0xFF00C853),
    warning:        Color(0xFFFF6D00),
  );

  @override
  AppColorTokens copyWith({
    Color? scaffoldBg,
    Color? surface,
    Color? backgroundGrey,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderLight,
    Color? divider,
    Color? shadow,
    Color? shadowLight,
    Color? error,
    Color? success,
    Color? warning,
  }) {
    return AppColorTokens(
      scaffoldBg:     scaffoldBg     ?? this.scaffoldBg,
      surface:        surface        ?? this.surface,
      backgroundGrey: backgroundGrey ?? this.backgroundGrey,
      inputFill:      inputFill      ?? this.inputFill,
      textPrimary:    textPrimary    ?? this.textPrimary,
      textSecondary:  textSecondary  ?? this.textSecondary,
      textTertiary:   textTertiary   ?? this.textTertiary,
      border:         border         ?? this.border,
      borderLight:    borderLight    ?? this.borderLight,
      divider:        divider        ?? this.divider,
      shadow:         shadow         ?? this.shadow,
      shadowLight:    shadowLight    ?? this.shadowLight,
      error:          error          ?? this.error,
      success:        success        ?? this.success,
      warning:        warning        ?? this.warning,
    );
  }

  @override
  AppColorTokens lerp(AppColorTokens? other, double t) {
    if (other == null) return this;
    return AppColorTokens(
      scaffoldBg:     Color.lerp(scaffoldBg,     other.scaffoldBg,     t)!,
      surface:        Color.lerp(surface,        other.surface,        t)!,
      backgroundGrey: Color.lerp(backgroundGrey, other.backgroundGrey, t)!,
      inputFill:      Color.lerp(inputFill,      other.inputFill,      t)!,
      textPrimary:    Color.lerp(textPrimary,    other.textPrimary,    t)!,
      textSecondary:  Color.lerp(textSecondary,  other.textSecondary,  t)!,
      textTertiary:   Color.lerp(textTertiary,   other.textTertiary,   t)!,
      border:         Color.lerp(border,         other.border,         t)!,
      borderLight:    Color.lerp(borderLight,    other.borderLight,    t)!,
      divider:        Color.lerp(divider,        other.divider,        t)!,
      shadow:         Color.lerp(shadow,         other.shadow,         t)!,
      shadowLight:    Color.lerp(shadowLight,    other.shadowLight,    t)!,
      error:          Color.lerp(error,          other.error,          t)!,
      success:        Color.lerp(success,        other.success,        t)!,
      warning:        Color.lerp(warning,        other.warning,        t)!,
    );
  }

  bool get isDark => scaffoldBg.computeLuminance() < 0.3;
}

/// Shorthand accessor: Theme.of(context).ext
extension AppColorTokensX on ThemeData {
  AppColorTokens get ext => extension<AppColorTokens>() ?? AppColorTokens.light;
  bool get isDark => brightness == Brightness.dark;
}
