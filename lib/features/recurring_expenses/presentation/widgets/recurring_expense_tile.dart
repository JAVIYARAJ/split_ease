import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import '../../domain/entities/recurring_expense_entity.dart';

class RecurringExpenseTile extends StatelessWidget {
  final RecurringExpenseEntity expense;
  final VoidCallback? onTogglePause;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const RecurringExpenseTile({
    super.key,
    required this.expense,
    this.onTogglePause,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_IN');
    final IconData iconData = IconUtils.getIconFromString(expense.categoryIcon);

    final String targetText = expense.categoryName;

    final bool isPaused = expense.isPaused;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaused
              ? Theme.of(context).ext.border.withValues(alpha: 0.2)
              : Theme.of(context).ext.border.withValues(alpha: 0.4),
        ),
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Icon, Title & Target, Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Category Icon Avatar
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isPaused
                            ? Theme.of(context).ext.border.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconData,
                        color: isPaused
                            ? Theme.of(context).ext.textTertiary
                            : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Target Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isPaused
                                  ? Theme.of(context).ext.textTertiary
                                  : Theme.of(context).ext.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.tag_rounded,
                                size: 12,
                                color: Theme.of(context).ext.textTertiary,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  targetText,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).ext.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Amount
                    Text(
                      "₹${currencyFormatter.format(expense.amount)}",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isPaused
                            ? Theme.of(context).ext.textTertiary
                            : Theme.of(context).ext.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(
                    height: 1,
                    color: Theme.of(context)
                        .ext
                        .border
                        .withValues(alpha: 0.2)),
                const SizedBox(height: 10),

                // Footer Row: Badges & Switch / Delete Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Badges: Due Date & Frequency Tag
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            // Due Date Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPaused
                                    ? Theme.of(context)
                                        .ext
                                        .border
                                        .withValues(alpha: 0.15)
                                    : AppColors.primaryTeal
                                        .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPaused
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.event_repeat_rounded,
                                    size: 13,
                                    color: isPaused
                                        ? Theme.of(context).ext.textTertiary
                                        : AppColors.primaryTeal,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPaused
                                        ? "Paused"
                                        : "Due ${DateFormat('MMM dd').format(expense.nextDueDate)}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isPaused
                                          ? Theme.of(context).ext.textTertiary
                                          : AppColors.primaryTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Frequency Tag Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .ext
                                    .border
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                expense.frequency.displayName,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).ext.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Right Action Controls: Switch & Delete
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 36,
                          child: Switch(
                            value: !isPaused,
                            onChanged: (_) => onTogglePause?.call(),
                            activeTrackColor: AppColors.primaryTeal,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.errorRed.withValues(alpha: 0.8),
                          ),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
