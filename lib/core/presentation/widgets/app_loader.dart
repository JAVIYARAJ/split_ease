import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  /// Whether the loader is being used as an overlay (adds semi-transparent background).
  final bool isOverlay;
  
  /// Custom color for the loader. Defaults to [AppColors.primaryTeal].
  final Color? color;

  const AppLoader({
    super.key,
    this.isOverlay = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget loader = CircularProgressIndicator.adaptive(
      valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primaryTeal),
      backgroundColor: Colors.white,
    );

    if (isOverlay) {
      return Container(
        color: Colors.black.withValues(alpha: 0.3), // Semi-transparent black for overlay
        child: Center(
          child: loader,
        ),
      );
    }

    return Center(child: loader);
  }
}
