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
    final isUnread = activity.isUnread;

    return Material(
      color: isUnread ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.backgroundLightGrey,
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with subtle status ring
              _buildIcon(isUnread),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title content column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                                  color: isUnread ? AppColors.textBlack : AppColors.textGrey,
                                  height: 1.3,
                                  decoration: (activity.activityAction == ActivityType.deleted || activity.activityAction == ActivityType.removed) 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Timestamp and Unread Dot
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDate(activity.createdAt),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.iconGrey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(height: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    
                    // Subtitle / Amount
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: (activity.activityAction == ActivityType.deleted || activity.activityAction == ActivityType.removed)
                              ? AppColors.textGrey
                              : (isPositive ? AppColors.successGreen : AppColors.warningOrange),
                          decoration: (activity.activityAction == ActivityType.deleted || activity.activityAction == ActivityType.removed) 
                                  ? TextDecoration.lineThrough 
                                  : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isUnread) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: activity.iconBgColor,
        borderRadius: BorderRadius.circular(14), // Modern squircle-like radius
        border: Border.all(
          color: activity.iconColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          activity.iconData, 
          color: activity.iconColor, 
          size: 22,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && date.day == now.day) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays == 1 || (difference.inDays < 2 && date.day != now.day)) {
      return 'Yesterday';
    } else if (now.year == date.year) {
      return DateFormat("MMM d").format(date);
    } else {
      return DateFormat("MMM d, y").format(date);
    }
  }
}
