import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundLightGrey,
                    image: friend.imageUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(friend.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: friend.imageUrl == null
                      ? Icon(Icons.person, color: AppColors.textGrey.withValues(alpha: 0.7))
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        friend.name,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (friend.balance != 0) ...[
                       Text(
                        friend.balance > 0 ? "owes you" : "you owe",
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          color: friend.balance > 0 ? AppColors.successGreen : AppColors.warningOrange,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "₹${friend.balance.abs().toStringAsFixed(2)}",
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: friend.balance > 0 ? AppColors.successGreen : AppColors.warningOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else 
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(
                           color: AppColors.backgroundLightGrey,
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Text(
                          "Settled",
                          style: GoogleFonts.openSans(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                                                 ),
                       ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: AppColors.textGrey.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
