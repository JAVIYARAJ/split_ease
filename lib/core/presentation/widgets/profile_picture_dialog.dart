import 'package:flutter/material.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class ProfilePictureDialog extends StatelessWidget {
  final String? avatarUrl;
  final String heroTag;

  const ProfilePictureDialog({
    super.key,
    required this.avatarUrl,
    required this.heroTag,
  });

  static void show(BuildContext context, {required String? avatarUrl, required String heroTag}) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProfilePictureDialog(avatarUrl: avatarUrl, heroTag: heroTag);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(), // Close if tapped outside the circle but inside dialog
        child: Stack(
          alignment: Alignment.center,
          children: [
            Hero(
              tag: heroTag,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: AppAvatar(
                  url: avatarUrl,
                  radius: MediaQuery.of(context).size.width * 0.4,
                  iconSize: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                  iconColor: AppColors.primaryTeal.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
