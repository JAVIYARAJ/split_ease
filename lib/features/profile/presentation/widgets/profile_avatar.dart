
import 'dart:io';
import 'package:flutter/material.dart';
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGrey, width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.backgroundLightGrey,
              backgroundImage: pickedImage != null
                  ? FileImage(pickedImage!)
                  : (avatarUrl != null && avatarUrl!.isNotEmpty)
                      ? NetworkImage(avatarUrl!) as ImageProvider
                      : null,
              child: (pickedImage == null && (avatarUrl == null || avatarUrl!.isEmpty))
                  ? const Icon(Icons.person, size: 60, color: AppColors.iconGrey)
                  : null,
            ),
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
