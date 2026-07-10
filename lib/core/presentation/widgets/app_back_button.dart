import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: onPressed ?? () => Navigator.maybePop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: color ?? Colors.white,
          size: 18,
        ),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
          fixedSize: const Size(40, 40),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
