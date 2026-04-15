
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final File? pickedImage; // Changed to accept passed file
  final VoidCallback onPickTrigger; // Changed to trigger parent

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.pickedImage,
    required this.onPickTrigger,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          AppAvatar(
            url: avatarUrl,
            file: pickedImage,
            radius: 60,
            iconSize: 60,
            backgroundColor: AppColors.backgroundLightGrey,
            iconColor: AppColors.iconGrey,
            border: Border.all(color: AppColors.borderGrey, width: 2),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: onPickTrigger,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
