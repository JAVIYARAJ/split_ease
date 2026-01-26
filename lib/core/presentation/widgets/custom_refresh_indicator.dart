import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primaryTeal,
      backgroundColor: backgroundColor ?? AppColors.backgroundWhite,
      child: child,
    );
  }
}
