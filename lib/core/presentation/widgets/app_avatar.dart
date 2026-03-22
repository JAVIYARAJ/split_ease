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
    
    final cleanUrl = url?.trim();
    final bool hasUrl = cleanUrl != null && cleanUrl.isNotEmpty && cleanUrl.toLowerCase() != 'null';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBackgroundColor,
        border: border,
      ),
      child: ClipOval(
        child: _buildAvatarContent(
          hasUrl: hasUrl,
          cleanUrl: cleanUrl,
          iconColor: effectiveIconColor,
          iconSize: effectiveIconSize,
        ),
      ),
    );
  }

  Widget _buildAvatarContent({
    required bool hasUrl,
    String? cleanUrl,
    required Color iconColor,
    required double iconSize,
  }) {
    if (file != null) {
      return Image.file(file!, fit: BoxFit.cover);
    }

    if (!hasUrl) {
      return Center(
        child: Icon(Icons.person_rounded, color: iconColor, size: iconSize),
      );
    }

    return CachedNetworkImage(
      imageUrl: cleanUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.transparent),
      errorWidget: (context, url, error) => Center(
        child: Icon(Icons.person_rounded, color: iconColor, size: iconSize),
      ),
    );
  }
}
