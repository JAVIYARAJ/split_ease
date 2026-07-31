import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import '../../../../core/presentation/widgets/app_back_button.dart';
import '../../../../core/routing/navigation_service.dart';
import '../../domain/entities/recurring_expense_entity.dart';
import '../bloc/add_edit_recurring_expense_bloc.dart';
import '../bloc/add_edit_recurring_expense_event.dart';
import '../bloc/add_edit_recurring_expense_state.dart';

class AddEditRecurringExpensePage extends StatelessWidget {
  final RecurringExpenseEntity? existingTemplate;

  const AddEditRecurringExpensePage({super.key, this.existingTemplate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddEditRecurringExpenseBloc()
        ..add(AddEditRecurringExpenseInitialized(existingTemplate)),
      child: _AddEditRecurringExpenseFormView(existingTemplate: existingTemplate),
    );
  }
}

class _AddEditRecurringExpenseFormView extends StatelessWidget {
  final RecurringExpenseEntity? existingTemplate;

  _AddEditRecurringExpenseFormView({this.existingTemplate});

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _onSave(BuildContext context) {
    final blocState = context.read<AddEditRecurringExpenseBloc>().state;
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : blocState.title;
    final amountText = _amountController.text.trim().isNotEmpty
        ? _amountController.text.trim()
        : blocState.amount;

    if (title.isEmpty) {
      AppAlerts.showError(context, 'Please enter a title for the recurring expense');
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      AppAlerts.showError(context, 'Please enter a valid amount');
      return;
    }

    final selectedCategory = blocState.selectedCategory;
    final categoryId = selectedCategory?.id ?? 'cat_general';
    final categoryName = selectedCategory?.name ?? 'General';
    final categoryIcon = selectedCategory?.icon ?? _getIconForTitle(title);

    final now = DateTime.now();
    final nextDue = DateTime(now.year, now.month + 1, blocState.dueDay);

    final newEntity = RecurringExpenseEntity(
      id: existingTemplate?.id ?? 'rec_${now.millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      frequency: blocState.frequency,
      dueDay: blocState.dueDay,
      nextDueDate: nextDue,
      isPaused: false,
      autoRemind: blocState.autoRemind,
    );

    AppAlerts.showSuccess(context, 'Recurring template saved!');
    Navigator.of(context).pop(newEntity);
  }

  Future<void> _showCategoryPicker(
      BuildContext context, AddEditRecurringExpenseState state) async {
    final result = await NavigationService.pushNamed(
      AppRoutes.categorySelection,
      args: {
        'categories': state.categories,
        'selectedCategory': state.selectedCategory,
      },
    );
    if (result != null && result is ExpenseCategoryEntity && context.mounted) {
      context
          .read<AddEditRecurringExpenseBloc>()
          .add(AddEditRecurringExpenseCategoryChanged(result));
    }
  }

  String _getIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('rent') || lower.contains('flat') || lower.contains('house')) {
      return 'home_rounded';
    }
    if (lower.contains('wifi') || lower.contains('net') || lower.contains('broadband')) {
      return 'wifi_rounded';
    }
    if (lower.contains('netflix') || lower.contains('tv') || lower.contains('ott')) {
      return 'tv_rounded';
    }
    if (lower.contains('electricity') || lower.contains('power') || lower.contains('light')) {
      return 'bolt_rounded';
    }
    if (lower.contains('gym') || lower.contains('fit')) {
      return 'fitness_center_rounded';
    }
    return 'receipt_long_rounded';
  }

  @override
  Widget build(BuildContext context) {
    if (existingTemplate != null && _titleController.text.isEmpty) {
      _titleController.text = existingTemplate!.title;
      _amountController.text = existingTemplate!.amount.toInt().toString();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).ext.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Theme.of(context).ext.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          onPressed: () {
            NavigationService.pop();
          },
        ),
        title: Text(
          existingTemplate != null ? "Edit Template" : "Add Recurring Expense",
          style: GoogleFonts.outfit(
            color: Theme.of(context).ext.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AddEditRecurringExpenseBloc, AddEditRecurringExpenseState>(
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Amount Card - Wide Centered Layout
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primaryTeal.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "RECURRING AMOUNT",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTeal,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "₹",
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.outfit(
                                fontSize: 38,
                                color: Theme.of(context).ext.textPrimary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              onChanged: (val) => context
                                  .read<AddEditRecurringExpenseBloc>()
                                  .add(AddEditRecurringExpenseAmountChanged(val)),
                              decoration: InputDecoration(
                                hintText: "0.00",
                                hintStyle: GoogleFonts.outfit(
                                  color: Theme.of(context)
                                      .ext
                                      .textTertiary
                                      .withValues(alpha: 0.4),
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Form Section Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).ext.border.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Input - Full Width
                      Text(
                        "Expense Name",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).ext.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        onChanged: (val) => context
                            .read<AddEditRecurringExpenseBloc>()
                            .add(AddEditRecurringExpenseTitleChanged(val)),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Theme.of(context).ext.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.edit_note_rounded,
                              color: AppColors.primaryTeal, size: 22),
                          hintText: "e.g., House Rent, WiFi, Netflix",
                          hintStyle: GoogleFonts.outfit(
                            color: Theme.of(context).ext.textTertiary,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).ext.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primaryTeal,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Category Selector Row
                      Text(
                        "Category",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).ext.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _showCategoryPicker(context, state),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).ext.inputFill,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.category_rounded,
                                  color: AppColors.primaryTeal,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  state.selectedCategory?.name ?? "General",
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).ext.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Theme.of(context).ext.textSecondary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Repeat Frequency Selector
                      Text(
                        "Repeat Frequency",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).ext.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: RecurrenceFrequency.values.map((freq) {
                          final isSelected = state.frequency == freq;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    context
                                        .read<AddEditRecurringExpenseBloc>()
                                        .add(AddEditRecurringExpenseFrequencyChanged(freq));
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryTeal
                                          : Theme.of(context).ext.inputFill,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryTeal
                                            : Theme.of(context)
                                                .ext
                                                .border
                                                .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        freq.displayName,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .ext
                                                  .textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Due Day Selector - Responsive Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTeal
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: AppColors.primaryTeal,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.frequency == RecurrenceFrequency.daily
                                            ? "Recurrence Schedule"
                                            : "Day of Month Due",
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .ext
                                              .textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        state.frequency == RecurrenceFrequency.daily
                                            ? "Triggers automatically every day"
                                            : "Bill due on day ${state.dueDay}",
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .ext
                                              .textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (state.frequency == RecurrenceFrequency.daily)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Every Day",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).ext.inputFill,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .ext
                                      .border
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: state.dueDay,
                                  isDense: true,
                                  dropdownColor: Theme.of(context).ext.surface,
                                  items: List.generate(28, (index) => index + 1)
                                      .map((day) => DropdownMenuItem<int>(
                                            value: day,
                                            child: Text("Day $day",
                                                style: GoogleFonts.outfit(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                    color: Theme.of(context)
                                                        .ext
                                                        .textPrimary)),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      context
                                          .read<AddEditRecurringExpenseBloc>()
                                          .add(AddEditRecurringExpenseDueDayChanged(val));
                                    }
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Auto Remind Switch - Responsive Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTeal
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_rounded,
                                    color: AppColors.primaryTeal,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Push Reminders",
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).ext.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: state.autoRemind,
                            onChanged: (val) {
                              context
                                  .read<AddEditRecurringExpenseBloc>()
                                  .add(AddEditRecurringExpenseRemindToggled(val));
                            },
                            activeTrackColor: AppColors.primaryTeal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Save Template Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _onSave(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Save Recurring Template",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
