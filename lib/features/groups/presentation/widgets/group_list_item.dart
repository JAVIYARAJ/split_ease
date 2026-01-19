import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/group_entity.dart';

class GroupListItem extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback? onTap;

  const GroupListItem({
    super.key,
    required this.group,
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
            // Group Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                   BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: group.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(group.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: group.imageUrl == null
                  ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                       gradient: const LinearGradient(
                          colors: [Color(0xFF4DB6AC), Color(0xFF009688)], // Teal gradient mockup
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                    ),
                    child: const Icon(Icons.list_alt, color: Colors.white, size: 28),
                  )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Name and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    group.name,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Balance Details List
                  ...group.balanceDetails.take(2).map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: RichText(
                      text: TextSpan(
                        text: '${detail.memberName} owes you ', // Simplify for mock match "Milan C. owes you ₹..."
                        style: GoogleFonts.openSans(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                        children: [
                          TextSpan(
                            text: '₹${detail.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w600,
                              color: detail.isOwedToUser ? const Color(0xFF009688) : AppColors.successGreen, // Using a specific teal/green from image
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  
                  if (group.balanceDetails.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        "Plus ${group.balanceDetails.length - 2} more balances",
                         style: GoogleFonts.openSans(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Balance Amount (Right side)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                   Text(
                    group.totalBalance > 0 ? "you are owed" : "you owe",
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: group.totalBalance > 0 ? const Color(0xFF009688) : AppColors.warningOrange, // Teal for owed
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  Text(
                    "₹${group.totalBalance.abs().toStringAsFixed(2)}",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: group.totalBalance > 0 ? const Color(0xFF009688) : AppColors.warningOrange,
                      fontWeight: FontWeight.bold,
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
