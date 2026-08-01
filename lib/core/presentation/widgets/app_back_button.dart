import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_layout.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double leftMargin;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.leftMargin = AppLayout.pageHorizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext = Theme.of(context).ext;

    final defaultIconColor = color ?? ext.textPrimary;
    final defaultBgColor = backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.05));

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: leftMargin),
        child: IconButton(
          onPressed: onPressed ?? () => Navigator.maybePop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: defaultIconColor,
            size: 18,
          ),
          style: IconButton.styleFrom(
            backgroundColor: defaultBgColor,
            fixedSize: const Size(40, 40),
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
          ),
        ),
      ),
    );
  }
}
