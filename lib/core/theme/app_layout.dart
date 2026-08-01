import 'package:flutter/material.dart';

/// Central design system layout tokens for consistent horizontal spacing and alignment.
class AppLayout {
  AppLayout._();

  /// Standard screen horizontal padding used across all pages (20.0 dp)
  static const double pageHorizontalPadding = 20.0;

  /// Standard AppBar leading width to accommodate AppBackButton starting at pageHorizontalPadding
  /// (20.0 left padding + 40.0 button width + 8.0 trailing space)
  static const double appBarLeadingWidth = 68.0;

  /// Standard EdgeInsets for page body content
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
  );

  /// Standard EdgeInsets for page body content with custom vertical padding
  static EdgeInsets pagePaddingWith({
    double top = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.fromLTRB(
      pageHorizontalPadding,
      top,
      pageHorizontalPadding,
      bottom,
    );
  }
}
