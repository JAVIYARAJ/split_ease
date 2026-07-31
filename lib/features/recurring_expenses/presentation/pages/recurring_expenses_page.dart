import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import '../../../../core/presentation/widgets/app_back_button.dart';
import '../../domain/entities/recurring_expense_entity.dart';
import '../bloc/recurring_expenses_bloc.dart';
import '../bloc/recurring_expenses_event.dart';
import '../bloc/recurring_expenses_state.dart';
import '../widgets/recurring_expense_tile.dart';

class RecurringExpensesPage extends StatelessWidget {
  const RecurringExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_IN');
    return Scaffold(
      backgroundColor: Theme.of(context).ext.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Theme.of(context).ext.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(onPressed: () {
          NavigationService.pop();
        },),
        title: Text(
          "Recurring Expenses",
          style: GoogleFonts.outfit(
            color: Theme.of(context).ext.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<RecurringExpensesBloc, RecurringExpensesState>(
        builder: (context, state) {
          if (state.status == RecurringExpensesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            );
          }

          final allItems = state.items;
          final activeItems = allItems.where((i) => !i.isPaused).toList();
          final pausedItems = allItems.where((i) => i.isPaused).toList();

          final filteredList = state.selectedFilterIndex == 0
              ? allItems
              : (state.selectedFilterIndex == 1 ? activeItems : pausedItems);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<RecurringExpensesBloc>().add(LoadRecurringExpensesEvent());
            },
            color: AppColors.primaryTeal,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
            slivers: [
              // Header Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF005B52)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "MONTHLY COMMITMENTS",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.75),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                "${activeItems.length} Active Templates",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "₹${currencyFormatter.format(state.totalMonthlyAmount)}",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Auto-calculated monthly commitments (Rent, WiFi, Subscriptions)",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filter Tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip(context, "All (${allItems.length})", 0,
                          state.selectedFilterIndex),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, "Active (${activeItems.length})",
                          1, state.selectedFilterIndex),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, "Paused (${pausedItems.length})",
                          2, state.selectedFilterIndex),
                    ],
                  ),
                ),
              ),

              // Smooth Animated Transition for Template List / Empty State
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: filteredList.isEmpty
                        ? Container(
                            key: const ValueKey('empty_recurring_state'),
                            child: _buildEmptyState(context),
                          )
                        : Column(
                            key: const ValueKey('list_recurring_state'),
                            children: filteredList.map((item) {
                              return RecurringExpenseTile(
                                key: ValueKey(item.id),
                                expense: item,
                                onTap: () async {
                                  final result = await NavigationService.pushNamed(
                                    AppRoutes.addEditRecurringExpense,
                                    args: item,
                                  );
                                  if (result != null && result is RecurringExpenseEntity && context.mounted) {
                                    context.read<RecurringExpensesBloc>().add(AddRecurringExpenseEvent(result));
                                  }
                                },
                                onTogglePause: () {
                                  context.read<RecurringExpensesBloc>().add(
                                        TogglePauseRecurringExpenseEvent(
                                            item.id),
                                      );
                                },
                                onDelete: () {
                                  _showDeleteConfirmationDialog(context, item);
                                },
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await NavigationService.pushNamed(
            AppRoutes.addEditRecurringExpense,
          );
          if (result != null && result is RecurringExpenseEntity && context.mounted) {
            context.read<RecurringExpensesBloc>().add(AddRecurringExpenseEvent(result));
          }
        },
        backgroundColor: AppColors.primaryTeal,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          "Add Template",
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, RecurringExpenseEntity item) {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_IN');
    final formattedAmount = '₹${currencyFormatter.format(item.amount)}';
    final frequencyName = item.frequency.displayName;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).ext.surface,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.errorRed,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Delete Template?",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).ext.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete \"${item.title}\" ($formattedAmount / $frequencyName)?",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).ext.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "This will permanently remove this recurring expense template and stop future automated reminders. Past expense records will remain unaffected.",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Theme.of(context).ext.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Theme.of(context).ext.border),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).ext.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<RecurringExpensesBloc>().add(
                              DeleteRecurringExpenseEvent(item.id),
                            );
                        AppAlerts.showSuccess(
                            context, '${item.title} template deleted');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.errorRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, int index,
      int selectedIndex) {
    final isSelected = selectedIndex == index;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : Theme.of(context).ext.textSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        context
            .read<RecurringExpensesBloc>()
            .add(FilterRecurringExpensesEvent(index));
      },
      selectedColor: AppColors.primaryTeal,
      backgroundColor: Theme.of(context).ext.surface,
      side: BorderSide(
        color: isSelected
            ? AppColors.primaryTeal
            : Theme.of(context).ext.border.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.autorenew_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Templates Found",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).ext.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Create a recurring expense template to automate\nyour rent, internet, and subscription bills.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Theme.of(context).ext.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
