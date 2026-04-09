import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/features/activity/presentation/utils/activity_ui_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/activity_entity.dart';

class ActivityListItem extends StatelessWidget {
  final ActivityEntity activity;
  final VoidCallback? onTap;

  const ActivityListItem({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get current user info for personalization
    final userState = context.read<AppUserCubit>().state;
    String? currentUserId;
    String? currentUserName;
    
    if (userState is AppUserLoggedIn) {
      currentUserId = userState.user.id;
      currentUserName = userState.user.name;
    }

    final title = activity.getDisplayTitle(currentUserId, currentUserName: currentUserName);
    final subtitle = activity.displaySubtitle;
    final isPositive = activity.isPositiveEffect;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            _buildIcon(),
            const SizedBox(width: 18),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Timestamp (Right Aligned)
                      Text(
                        _formatDate(activity.createdAt),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.iconGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Subtitle (Amount detail)
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? AppColors.successGreen : AppColors.warningOrange,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: activity.iconBgColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(activity.iconData, color: activity.iconColor, size: 24),
          ),
          // Small circle overlay to highlight nature of activity
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: activity.isPositiveEffect ? AppColors.successGreen : (activity.displaySubtitle != null ? AppColors.warningOrange : activity.iconColor),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0 && date.day == now.day) {
      return DateFormat('h:mm a').format(date); // e.g., 2:30 PM
    } else if (now.year == date.year) {
      return DateFormat("MMM d").format(date); // e.g., Oct 9
    } else {
      return DateFormat("MMM d, y").format(date); // e.g., Oct 9, 2024
    }
  }
}
