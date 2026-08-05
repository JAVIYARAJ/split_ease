import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/profile_picture_dialog.dart';
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
    Color statusColor = Theme.of(context).ext.textTertiary;
    String subtitleText = "";
    bool showBalance = true;

    if (friend.overallBalance > 0) {
      statusColor = AppColors.successGreen;
      subtitleText = "${friend.name} owes you";
    } else if (friend.overallBalance < 0) {
      statusColor = AppColors.warningOrange;
      subtitleText = "You owe ${friend.name}";
    } else {
      subtitleText = "You and ${friend.name} are fully settled up";
      showBalance = false;
    }

    final formatter = NumberFormat('#,##0.00', 'en_IN');
    
    int nestedItemsCount = friend.groupBreakdown.length;
    if (friend.nonGroupBalance != 0) {
      nestedItemsCount++;
    }

    final bool showNested = showBalance && nestedItemsCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () {
                        ProfilePictureDialog.show(
                          context,
                          avatarUrl: friend.imageUrl,
                          name: friend.name,
                          heroTag: friend.id,
                        );
                      },
                      child: Hero(
                        tag: friend.id,
                        child: AppAvatar(
                          url: friend.imageUrl,
                          radius: 26,
                          backgroundColor: Theme.of(context).ext.backgroundGrey,
                          iconColor: Theme.of(context).ext.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Name and Subtitle
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.name,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).ext.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitleText,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: showBalance ? statusColor : Theme.of(context).ext.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Overall Balance
                    if (showBalance)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "₹${formatter.format(friend.overallBalance.abs())}",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Nested Breakdowns
                if (showNested)
                  Padding(
                    padding: const EdgeInsets.only(left: 26.0, top: 12.0), // Align under the center of the icon
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < friend.groupBreakdown.length; i++)
                          _buildNestedBalanceRow(context, 
                            contextName: friend.groupBreakdown[i].groupName,
                            balance: friend.groupBreakdown[i].balance,
                            formatter: formatter,
                            isLast: (i == friend.groupBreakdown.length - 1) && friend.nonGroupBalance == 0,
                          ),
                        if (friend.nonGroupBalance != 0)
                          _buildNestedBalanceRow(context, 
                            contextName: "Non-group expense",
                            balance: friend.nonGroupBalance,
                            formatter: formatter,
                            isLast: true,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNestedBalanceRow(BuildContext context, {
    required String contextName,
    required double balance,
    required NumberFormat formatter,
    required bool isLast,
  }) {
    String textStatus = "owes you";
    Color color = AppColors.successGreen;
    if (balance < 0) {
      textStatus = "you owe";
      color = AppColors.warningOrange;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomPaint(
            size: const Size(20, double.infinity),
            painter: _TreeBranchPainter(
              isLast: isLast,
              color: Theme.of(context).ext.border,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$textStatus ",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Theme.of(context).ext.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: "₹${formatter.format(balance.abs())} ",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: "in $contextName",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Theme.of(context).ext.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeBranchPainter extends CustomPainter {
  final bool isLast;
  final Color color;

  _TreeBranchPainter({required this.isLast, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double verticalLineEnd = isLast ? size.height / 2 : size.height;
    
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, verticalLineEnd),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
