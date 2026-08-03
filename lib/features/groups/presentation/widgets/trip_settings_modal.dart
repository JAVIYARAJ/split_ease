import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';

class TripSettingsModal extends StatefulWidget {
  final GroupEntity group;
  final Function({
    required String destination,
    required String? startDate,
    required String? endDate,
    required double? budget,
  }) onSave;

  const TripSettingsModal({
    super.key,
    required this.group,
    required this.onSave,
  });

  @override
  State<TripSettingsModal> createState() => _TripSettingsModalState();
}

class _TripSettingsModalState extends State<TripSettingsModal> {
  late TextEditingController _destController;
  late TextEditingController _budgetController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _destController = TextEditingController(text: widget.group.destination ?? '');
    _budgetController = TextEditingController(
      text: widget.group.budget != null && widget.group.budget! > 0
          ? widget.group.budget!.toStringAsFixed(0)
          : '',
    );
    try {
      if (widget.group.startDate != null) {
        _startDate = DateTime.parse(widget.group.startDate!);
      }
      if (widget.group.endDate != null) {
        _endDate = DateTime.parse(widget.group.endDate!);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _destController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).ext.surface,
              onSurface: Theme.of(context).ext.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0.8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).ext;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ext.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ext.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Trip Settings & Budget ✈️",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ext.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Inputs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination Name
                  _buildSectionLabel("TRIP DESTINATION"),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: ext.inputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ext.border.withValues(alpha: 0.3)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _destController,
                      maxLines: 1,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: ext.textPrimary),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: "E.g. Goa, Paris, Bali",
                        hintStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: ext.textTertiary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Travel Dates
                  _buildSectionLabel("TRAVEL DATES"),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDateRange,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ext.inputFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ext.border.withValues(alpha: 0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 20, color: ext.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _startDate != null && _endDate != null
                                  ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}'
                                  : 'Select Travel Dates',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: _startDate != null ? FontWeight.w600 : FontWeight.w500,
                                color: _startDate != null ? ext.textPrimary : ext.textTertiary,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down_rounded, color: ext.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Target Budget
                  _buildSectionLabel("TARGET TRIP BUDGET"),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: ext.inputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ext.border.withValues(alpha: 0.3)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: ext.textPrimary),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: "E.g. 50000",
                        hintStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: ext.textTertiary),
                        prefixText: "₹ ",
                        prefixStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Submit Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final String dest = _destController.text.trim();
                    final double? budget = double.tryParse(_budgetController.text.trim());
                    final String? start = _startDate?.toIso8601String();
                    final String? end = _endDate?.toIso8601String();

                    widget.onSave(
                      destination: dest,
                      startDate: start,
                      endDate: end,
                      budget: budget,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
