import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/features/groups/domain/entities/group_type.dart';
import '../../../../../core/presentation/widgets/app_image_view.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/group_entity.dart';
import 'package:intl/intl.dart';

class GroupListItem extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback? onTap;

  const GroupListItem({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine overall status colors and text
    Color statusColor = AppColors.textGrey;
    String statusText = "";
    bool showBalance = true;

    if (group.status == "you_are_owed") {
      statusColor = AppColors.primaryTeal;
      statusText = "you are owed";
    } else if (group.status == "you_owe") {
      statusColor = AppColors.warningOrange; // Assuming orange for owe
      statusText = "you owe";
    } else {
      statusText = "settled up";
      showBalance = false;
    }

    final formatter = NumberFormat('#,##0.00', 'en_IN');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreyLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column( // Use a column to stack main row and nested rows
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group Icon 
                    Hero(
                      tag: group.id ?? "group_${group.name}",
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.backgroundLightGrey,
                          border: Border.all(color: AppColors.borderGreyLight, width: 0.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: group.groupIcon != null
                              ? AppImageView(
                                  url: group.groupIcon,
                                  height: 52,
                                  width: 52,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.backgroundLightGrey,
                                  child: Icon(
                                    _getIconData(group.groupType),
                                    color: AppColors.textGrey,
                                    size: 26,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Name
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0), // Align name slightly down
                        child: Text(
                          group.name ?? "Non-group",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Overall Balance
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            statusText,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (showBalance && group.overallBalance != null)
                            Text(
                              "₹${formatter.format(group.overallBalance!.abs())}",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Nested Member Balances
                if (group.balancePreview != null && group.balancePreview!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 26.0, top: 12.0), // Align under the center of the icon
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < group.balancePreview!.length; i++)
                          _buildNestedBalanceRow(
                            name: group.balancePreview![i].fullName ?? 'Unknown',
                            balance: group.balancePreview![i].balance ?? 0.0,
                            formatter: formatter,
                            isLast: i == group.balancePreview!.length - 1 && (group.totalActiveBalances ?? 0) <= group.balancePreview!.length,
                          ),
                        if (group.totalActiveBalances != null && group.totalActiveBalances! > group.balancePreview!.length)
                          _buildPlusMoreBalancesRow(
                            count: group.totalActiveBalances! - group.balancePreview!.length,
                          ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNestedBalanceRow({
    required String name,
    required double balance,
    required NumberFormat formatter,
    required bool isLast,
  }) {
    // Determine individual status
    String textStatus = "owes you";
    Color color = AppColors.primaryTeal;
    if (balance < 0) {
      textStatus = "you owe";
      color = AppColors.warningOrange;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The tree branching line
          CustomPaint(
            size: const Size(20, double.infinity),
            painter: _TreeBranchPainter(isLast: isLast),
          ),
          const SizedBox(width: 8),
          
          // Data
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$name $textStatus ",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: "₹${formatter.format(balance.abs())}",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlusMoreBalancesRow({required int count}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomPaint(
            size: const Size(20, double.infinity),
            painter: _TreeBranchPainter(isLast: true),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "Plus $count more balances",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? type) {
    if (type == GroupType.home.name) {
      return Icons.home_rounded;
    } else if (type == GroupType.couple.name) {
      return Icons.favorite_rounded;
    } else if (type == GroupType.trip.name) {
      return Icons.flight_takeoff_rounded;
    } else {
      return Icons.list_alt_rounded;
    }
  }
}

class _TreeBranchPainter extends CustomPainter {
  final bool isLast;

  _TreeBranchPainter({required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Line running down from top
    final double verticalLineEnd = isLast ? size.height / 2 : size.height;
    
    // Draw vertical line from top
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, verticalLineEnd),
      paint,
    );

    // Draw horizontal branch exactly in the middle of this item's height
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
