import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
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
    Color statusColor = Theme.of(context).ext.textTertiary;
    String subtitleText = "";
    bool showBalance = true;

    if (group.status == "you_are_owed") {
      statusColor = AppColors.primaryTeal;
      subtitleText = "You are owed";
    } else if (group.status == "you_owe") {
      statusColor = AppColors.warningOrange; 
      subtitleText = "You owe";
    } else {
      subtitleText = "You are fully settled up in this group";
      showBalance = false;
    }

    final formatter = NumberFormat('#,##0.00', 'en_IN');

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
                          color: Theme.of(context).ext.backgroundGrey,
                          border: Border.all(color: Theme.of(context).ext.borderLight, width: 0.5),
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
                                  color: Theme.of(context).ext.backgroundGrey,
                                  child: Icon(
                                    _getIconData(group.groupType),
                                    color: Theme.of(context).ext.textSecondary,
                                    size: 26,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name and Subtitle
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name ?? "Non-group expense",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).ext.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (group.groupType != null) ...[
                                  _buildCategoryPill(context, group.groupType!),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    subtitleText,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: showBalance ? statusColor : Theme.of(context).ext.textTertiary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (showBalance && group.overallBalance != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    "₹${formatter.format(group.overallBalance!.abs())}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
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
                          _buildNestedBalanceRow(context,
                            name: group.balancePreview![i].fullName ?? 'Unknown',
                            balance: group.balancePreview![i].balance ?? 0.0,
                            formatter: formatter,
                            isLast: i == group.balancePreview!.length - 1 && (group.totalActiveBalances ?? 0) <= group.balancePreview!.length,
                          ),
                        if (group.totalActiveBalances != null && group.totalActiveBalances! > group.balancePreview!.length)
                          _buildPlusMoreBalancesRow(context,
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

  Widget _buildNestedBalanceRow(BuildContext context, {
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
                            painter: _TreeBranchPainter(isLast: isLast, lineColor: Theme.of(context).ext.border.withValues(alpha: 0.5)),
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
                                        color: Theme.of(context).ext.textSecondary,
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

                  Widget _buildPlusMoreBalancesRow(BuildContext context, {required int count}) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomPaint(
                            size: const Size(20, double.infinity),
                            painter: _TreeBranchPainter(isLast: true, lineColor: Theme.of(context).ext.border.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                "Plus $count more balances",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Theme.of(context).ext.textSecondary,
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

                  Widget _buildCategoryPill(BuildContext context, String type) {
                    String label = "General";
                    Color color = AppColors.primaryTeal;

                    if (type == 'trip') {
                      label = "Trip ✈️";
                      color = const Color(0xFF0284C7);
                    } else if (type == 'home') {
                      label = "Home 🏠";
                      color = const Color(0xFF16A34A);
                    } else if (type == 'couple') {
                      label = "Duo 💑";
                      color = const Color(0xFFE11D48);
                    } else if (type == 'other') {
                      label = "Other 📁";
                      color = const Color(0xFF8B5CF6);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    );
                  }
                }

                class _TreeBranchPainter extends CustomPainter {
                  final bool isLast;
                  final Color lineColor;

                  _TreeBranchPainter({required this.isLast, required this.lineColor});

                  @override
                  void paint(Canvas canvas, Size size) {
                    final paint = Paint()
                      ..color = lineColor
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
