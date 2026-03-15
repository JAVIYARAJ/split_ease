import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? url;
  final File? file;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final BoxBorder? border;

  const AppAvatar({
    super.key,
    this.url,
    this.file,
    this.radius = 24,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primary.withValues(alpha: 0.1);
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveIconSize = iconSize ?? (radius * 1.2);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBackgroundColor,
        border: border,
        image: file != null
            ? DecorationImage(
                image: FileImage(file!),
                fit: BoxFit.cover,
              )
            : (url != null && url!.isNotEmpty)
                ? DecorationImage(
                    image: CachedNetworkImageProvider(url!),
                    fit: BoxFit.cover,
                  )
                : null,
      ),
      child: (file == null && (url == null || url!.isEmpty))
          ? Center(
              child: Icon(
                Icons.person_rounded,
                color: effectiveIconColor,
                size: effectiveIconSize,
              ),
            )
          : null,
    );
  }
}
