import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
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
    final isDeleted = activity.activityAction == ActivityType.deleted ||
        activity.activityAction == ActivityType.removed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.primaryTeal.withValues(alpha: 0.08)
            : Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread
              ? AppColors.primaryTeal
              : Theme.of(context).ext.border.withValues(alpha: 0.4),
          width: isUnread ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? AppColors.primaryTeal.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: isUnread
                ? AppColors.primaryTeal.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Indicator Strip for Unread Items
              if (isUnread)
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTeal,
                  ),
                ),

              // Main Card Content
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: AppColors.primaryTeal.withValues(alpha: 0.08),
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Gradient Icon Squircle
                              _buildHeroIcon(isUnread, context),
                              const SizedBox(width: 14),

                              // Text Content Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title Text
                                    Text(
                                      title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14.5,
                                        fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                        color: isDeleted ? Theme.of(context).ext.textTertiary : Theme.of(context).ext.textPrimary,
                                        height: 1.3,
                                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 6),

                                    // Time + Group Scope Pill Row
                                    Row(
                                      children: [
                                        // Time Chip
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: isUnread ? AppColors.primaryTeal : Theme.of(context).ext.textTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(activity.createdAt),
                                          style: GoogleFonts.outfit(
                                            fontSize: 11.5,
                                            color: isUnread ? AppColors.primaryTeal : Theme.of(context).ext.textTertiary,
                                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                          ),
                                        ),

                                        // Optional Group Scope Tag
                                        if (activity.groupName != null && activity.groupName!.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).ext.backgroundGrey,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.group_rounded,
                                                  size: 10,
                                                  color: Theme.of(context).ext.textSecondary,
                                                ),
                                                const SizedBox(width: 3),
                                                Flexible(
                                                  child: Text(
                                                    activity.groupName!,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: Theme.of(context).ext.textSecondary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Chevron / Unread Dot
                              if (onTap != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6, top: 2),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: Theme.of(context).ext.textTertiary.withValues(alpha: 0.5),
                                  ),
                                ),
                            ],
                          ),

                          // Subtitle / Amount Pill Bar (if available)
                          if (subtitle != null) ...[
                            const SizedBox(height: 10),
                            _buildAmountPill(context, subtitle, isPositive, isDeleted),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIcon(bool isUnread, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: activity.iconGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: activity.iconColor.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              activity.iconData,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        if (isUnread)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).ext.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAmountPill(BuildContext context, String subtitle, bool isPositive, bool isDeleted) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgStart;
    Color bgEnd;
    Color borderColor;
    Color textColor;
    IconData iconData;

    if (isDeleted) {
      bgStart = Theme.of(context).ext.backgroundGrey;
      bgEnd = Theme.of(context).ext.backgroundGrey;
      borderColor = Theme.of(context).ext.border;
      textColor = Theme.of(context).ext.textTertiary;
      iconData = Icons.remove_circle_outline_rounded;
    } else if (isPositive) {
      bgStart = isDark ? AppColors.successGreen.withValues(alpha: 0.15) : const Color(0xFFE8F5E9);
      bgEnd = isDark ? AppColors.successGreen.withValues(alpha: 0.25) : const Color(0xFFC8E6C9);
      borderColor = isDark ? AppColors.successGreen.withValues(alpha: 0.4) : const Color(0xFFA5D6A7);
      textColor = isDark ? AppColors.successGreen : const Color(0xFF1B5E20);
      iconData = Icons.south_west_rounded;
    } else {
      bgStart = isDark ? AppColors.errorRed.withValues(alpha: 0.15) : const Color(0xFFFFF3E0);
      bgEnd = isDark ? AppColors.errorRed.withValues(alpha: 0.25) : const Color(0xFFFFE0B2);
      borderColor = isDark ? AppColors.errorRed.withValues(alpha: 0.4) : const Color(0xFFFFCC80);
      textColor = isDark ? AppColors.errorRed : const Color(0xFFBF360C);
      iconData = Icons.north_east_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgStart, bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 13,
            color: textColor,
          ),
          const SizedBox(width: 5),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
              decoration: isDeleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
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
