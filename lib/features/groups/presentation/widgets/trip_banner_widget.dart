import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';

class TripBannerWidget extends StatelessWidget {
  final GroupEntity group;
  final double totalExpenses;
  final VoidCallback onConfigureTrip;

  const TripBannerWidget({
    super.key,
    required this.group,
    required this.totalExpenses,
    required this.onConfigureTrip,
  });

  @override
  Widget build(BuildContext context) {
    if (group.groupType != 'trip') return const SizedBox.shrink();

    final ext = Theme.of(context).ext;
    final formatter = NumberFormat('#,##0.##', 'en_IN');

    final String destination = group.destination?.trim().isNotEmpty == true
        ? group.destination!
        : 'Set Trip Destination';

    final String dateRange = _formatDateRange(group.startDate, group.endDate);
    final _TripStatusTag? statusTag =
        _getTripStatusTag(group.startDate, group.endDate);
    final double? budget = group.budget;
    final bool hasBudget = budget != null && budget > 0;

    final double progress = hasBudget
        ? (totalExpenses / budget).clamp(0.0, 1.0)
        : 0.0;
    final double percent = hasBudget
        ? (totalExpenses / budget * 100).clamp(0.0, 999.0)
        : 0.0;

    final Color statusColor = percent > 100
        ? ext.error
        : (percent > 80 ? ext.warning : AppColors.primaryTeal);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.border.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.primaryTeal, width: 4),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.flight_takeoff_rounded,
                              size: 16,
                              color: AppColors.primaryTeal,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                destination,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: ext.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (dateRange.isNotEmpty || statusTag != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (dateRange.isNotEmpty)
                                Text(
                                  dateRange,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: ext.textSecondary,
                                  ),
                                ),
                              if (statusTag != null) ...[
                                if (dateRange.isNotEmpty)
                                  const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusTag.color
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: statusTag.color
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        statusTag.icon,
                                        size: 11,
                                        color: statusTag.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusTag.label,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: statusTag.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action Button
                  GestureDetector(
                    onTap: onConfigureTrip,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        hasBudget ? 'Edit' : 'Setup Budget',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Progress Section
              if (hasBudget) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${formatter.format(totalExpenses)} spent',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ext.textPrimary,
                      ),
                    ),
                    Text(
                      'Budget: ₹${formatter.format(budget)} (${percent.toStringAsFixed(0)}%)',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: ext.backgroundGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _TripStatusTag? _getTripStatusTag(String? startStr, String? endStr) {
    final now = DateTime.now();

    // 1. Check if Trip Ended
    if (endStr != null && endStr.trim().isNotEmpty) {
      try {
        final endDate = DateTime.parse(endStr);
        final endOfTripDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );
        if (now.isAfter(endOfTripDay)) {
          return const _TripStatusTag(
            label: 'Trip Ended',
            icon: Icons.flag_rounded,
            color: AppColors.warningOrange,
          );
        }
      } catch (_) {}
    }

    // 2. Check if Starts Soon (within 3 days: 0, 1, 2, or 3 days until start)
    if (startStr != null && startStr.trim().isNotEmpty) {
      try {
        final startDate = DateTime.parse(startStr);
        final todayStart = DateTime(now.year, now.month, now.day);
        final startOfTripDay = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final daysUntilStart = startOfTripDay.difference(todayStart).inDays;

        if (daysUntilStart >= 0 && daysUntilStart <= 3) {
          final String label = daysUntilStart == 0
              ? 'Starts Today'
              : (daysUntilStart == 1 ? 'Starts Tomorrow' : 'Starts Soon');
          return _TripStatusTag(
            label: label,
            icon: Icons.schedule_rounded,
            color: const Color(0xFF0284C7),
          );
        }
      } catch (_) {}
    }

    return null;
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null || start.isEmpty) return '';
    try {
      final startDate = DateTime.parse(start);
      final startFmt = DateFormat('MMM d').format(startDate);

      if (end != null && end.isNotEmpty) {
        final endDate = DateTime.parse(end);
        final endFmt = DateFormat('MMM d, yyyy').format(endDate);
        return '$startFmt - $endFmt';
      }
      return startFmt;
    } catch (_) {
      return '';
    }
  }
}

class _TripStatusTag {
  final String label;
  final IconData icon;
  final Color color;

  const _TripStatusTag({
    required this.label,
    required this.icon,
    required this.color,
  });
}
