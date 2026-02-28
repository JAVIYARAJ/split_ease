import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
                          activity.title,
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
                        _formatDate(activity.timestamp),
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
                  if (activity.subtitle != null)
                    Text(
                      activity.subtitle!,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: activity.isPositive ? AppColors.successGreen : AppColors.warningOrange,
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
    IconData iconData;
    Color iconColor;
    Color bgColor;
    
    switch (activity.type) {
      case ActivityType.settlement:
        iconData = Icons.account_balance_wallet_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      case ActivityType.expense:
        iconData = Icons.receipt_long_rounded;
        iconColor = AppColors.warningOrange;
        bgColor = AppColors.warningOrange.withValues(alpha: 0.1);
        break;
      case ActivityType.payment:
        iconData = Icons.payments_rounded;
        iconColor = AppColors.successGreen;
        bgColor = AppColors.successGreen.withValues(alpha: 0.1);
        break;
      case ActivityType.modification:
        iconData = Icons.edit_note_rounded;
        iconColor = Colors.blue.shade600;
        bgColor = Colors.blue.shade600.withValues(alpha: 0.1);
        break;
      case ActivityType.addToGroup:
        iconData = Icons.group_add_rounded;
        iconColor = Colors.purple.shade500;
        bgColor = Colors.purple.shade500.withValues(alpha: 0.1);
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          // Small circle overlay to highlight nature of activity
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: activity.isPositive ? AppColors.successGreen : (activity.subtitle != null ? AppColors.warningOrange : iconColor),
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

