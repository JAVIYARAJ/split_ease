import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppImageView extends StatelessWidget {
  final String? url;
  final String? assetPath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double radius;
  final Color? backgroundColor;

  const AppImageView({
    super.key,
    this.url,
    this.assetPath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null && assetPath == null) {
      return const SizedBox();
    }

    Widget imageWidget;

    if (url != null && url!.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: url!,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(
          height: height,
          width: width,
          color: backgroundColor ?? Colors.grey.shade200,
        ),
        errorWidget: (context, url, error) => Container(
          height: height,
          width: width,
          color: backgroundColor ?? Colors.grey.shade200,
          child: const Icon(Icons.error_outline, color: Colors.grey),
        ),
      );
    } else {
      imageWidget = Image.asset(
        assetPath!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: backgroundColor ?? Colors.grey.shade200,
          child: const Icon(Icons.error_outline, color: Colors.grey),
        ),
      );
    }

    if (radius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
