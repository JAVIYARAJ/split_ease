import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/friend_entity.dart';

class FriendListItem extends StatelessWidget {
  final FriendEntity friend;
  final VoidCallback? onTap;

  const FriendListItem({
    super.key,
    required this.friend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                image: friend.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(friend.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: friend.imageUrl == null
                  ? Icon(Icons.person, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Name and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    friend.name,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                   if (friend.balance != 0) ...[
                     const SizedBox(height: 4),
                     // Description logic matches "Overall, you owe" context? 
                     // Actually per item:
                     // If positive: "owes you"
                     // If negative: "you owe"
                     // Detail text: e.g. "activeGroup"
                     // The image shows complex details, keeping it simpler for now but close to image
                     // Image shows: "Bhruvik M. owes you ₹3,331.85 in 'groupname'"
                     
                     // We will use a simplified text for now based on the Entity's balance
                     if (friend.balance > 0)
                      Text(
                         "owes you ₹${friend.balance.toStringAsFixed(2)}",
                         style: GoogleFonts.openSans(
                           fontSize: 13,
                           color: AppColors.successGreen,
                           fontWeight: FontWeight.w500,
                         ),
                       )
                     else
                       Text(
                         "you owe ₹${friend.balance.abs().toStringAsFixed(2)}",
                         style: GoogleFonts.openSans(
                           fontSize: 13,
                           color: AppColors.warningOrange,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                   ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        "settled up",
                        style: GoogleFonts.openSans(
                           fontSize: 13,
                           color: AppColors.textGrey,
                           fontWeight: FontWeight.w500,
                         ),
                      ),
                   ]
                ],
              ),
            ),
            
            // Balance Amount (Right side)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (friend.balance != 0) ...[
                   Text(
                    friend.balance > 0 ? "owes you" : "you owe",
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: friend.balance > 0 ? AppColors.successGreen : AppColors.warningOrange,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  Text(
                    "₹${friend.balance.abs().toStringAsFixed(2)}",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: friend.balance > 0 ? AppColors.successGreen : AppColors.warningOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else 
                   Text(
                    "settled up",
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
