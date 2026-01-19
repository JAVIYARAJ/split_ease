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
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    activity.title,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: AppColors.textBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Subtitle (Amount detail)
                  if (activity.subtitle != null)
                    Text(
                      activity.subtitle!,
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: activity.isPositive ? AppColors.successGreen : AppColors.warningOrange,
                      ),
                    ),
                  
                   const SizedBox(height: 4),
                   // Timestamp
                    Text(
                      _formatDate(activity.timestamp),
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        color: AppColors.textGrey,
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
    
    switch (activity.type) {
      case ActivityType.settlement:
        iconData = Icons.balance_rounded; // Scales icon
        iconColor = Colors.grey.shade700;
        break;
      case ActivityType.expense:
        iconData = Icons.receipt_long_rounded; // Receipt icon
        iconColor = Colors.grey.shade700;
        break;
      case ActivityType.payment:
        iconData = Icons.payments_rounded; // Banknote/Payment icon
        iconColor = const Color(0xFF009688);
        break;
      case ActivityType.modification:
        iconData = Icons.edit_note_rounded;
        iconColor = Colors.grey.shade700;
        break;
      case ActivityType.addToGroup:
        iconData = Icons.group_add_rounded;
        iconColor = Colors.grey.shade700;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(iconData, color: iconColor, size: 28),
          ),
          // Small circle overlay as seen in design (e.g. user avatar color indicator)
          // Simplified as a colored dot for now
          // Positioned bottom right
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.red.shade900, // Example color from image
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
    // Format: "9 Oct 2025 at 11:07 AM"
    return DateFormat("d MMM y 'at' h:mm a").format(date);
  }
}
