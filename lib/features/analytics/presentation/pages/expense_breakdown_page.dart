import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_formatter.dart';
import 'package:split_ease/core/presentation/widgets/animations/animated_counter_text.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import '../../domain/entities/expense_breakdown_entity.dart';
import '../bloc/expense_breakdown_bloc.dart';
import '../bloc/expense_breakdown_event.dart';
import '../bloc/expense_breakdown_state.dart';

class ExpenseBreakdownPage extends StatefulWidget {
  const ExpenseBreakdownPage({super.key});

  @override
  State<ExpenseBreakdownPage> createState() => _ExpenseBreakdownPageState();
}

class _ExpenseBreakdownPageState extends State<ExpenseBreakdownPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBreakdownBloc>().add(const LoadExpenseBreakdown());
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      context.read<ExpenseBreakdownBloc>().add(LoadExpenseBreakdown(
        filter: AnalyticsFilter.custom,
        customStart: picked.start,
        customEnd: picked.end,
      ));
    }
  }

  void _showFilterSheet(ExpenseBreakdownState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterBottomSheet(
        activeFilter: state.activeFilter,
        customStart: state.customStart,
        customEnd: state.customEnd,
        onFilterSelected: (filter) {
          Navigator.pop(context);
          if (filter == AnalyticsFilter.custom) {
            _showDateRangePicker();
          } else {
            context.read<ExpenseBreakdownBloc>().add(LoadExpenseBreakdown(filter: filter));
          }
        },
      ),
    );
  }

  String _filterLabel(AnalyticsFilter f, {DateTime? customStart, DateTime? customEnd}) {
    switch (f) {
      case AnalyticsFilter.thisWeek:  return 'This Week';
      case AnalyticsFilter.lastWeek:  return 'Last Week';
      case AnalyticsFilter.thisMonth: return 'This Month';
      case AnalyticsFilter.lastMonth: return 'Last Month';
      case AnalyticsFilter.thisYear:  return 'This Year';
      case AnalyticsFilter.custom:
        if (customStart != null && customEnd != null) {
          final fmt = DateFormat('MMM d');
          return '${fmt.format(customStart)} – ${fmt.format(customEnd)}';
        }
        return 'Custom Range';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Analytics",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        leading: AppBackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<ExpenseBreakdownBloc, ExpenseBreakdownState>(
        builder: (context, state) {
          final isLoading = state.status == ExpenseBreakdownStatus.loading ||
              state.status == ExpenseBreakdownStatus.initial;

          if (state.status == ExpenseBreakdownStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
                  const SizedBox(height: 16),
                  Text(state.errorMessage, style: GoogleFonts.outfit(color: AppColors.textGrey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ExpenseBreakdownBloc>()
                        .add(LoadExpenseBreakdown(filter: state.activeFilter)),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final dummyBreakdown = ExpenseBreakdownEntity(
            summary: const ExpenseBreakdownSummaryEntity(
              totalSpent: 1500,
              groupExpenseShare: 800,
              personalExpenseShare: 500,
              nonGroupExpenseShare: 200,
            ),
            categoryBreakdown: List.generate(
              5,
              (index) => CategoryDetailEntity(
                id: "$index",
                icon: "category",
                name: "Loading Category",
                color: "#CCCCCC",
                amount: 300,
                categoryPercentage: 20,
                budgetPercentage: 10,
                expenseCount: 2,
              ),
            ),
          );

          final displayData = isLoading ? dummyBreakdown : state.breakdown;
          if (displayData == null) return const SizedBox.shrink();

          return Skeletonizer(
            enabled: isLoading,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context
                    .read<ExpenseBreakdownBloc>()
                    .add(LoadExpenseBreakdown(filter: state.activeFilter));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Collapsible header with amount + filter pill ──
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: AppColors.backgroundWhite,
                    elevation: 0,
                    expandedHeight: 140,
                    collapsedHeight: 64,
                    toolbarHeight: 64,
                    flexibleSpace: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints) {
                        final top = constraints.biggest.height;
                        final percent = ((top - 64) / (140 - 64)).clamp(0.0, 1.0);

                        return ClipRect(
                          child: Container(
                            color: AppColors.backgroundWhite,
                            child: Stack(
                              children: [
                                // "Total Expenses" label
                                Positioned(
                                  left: 24,
                                  top: 10 + (14 * percent),
                                  child: Text(
                                    "Total Expenses",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12 + (2 * percent),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ),
                                // Amount
                                Positioned(
                                  left: 24,
                                  right: 140,
                                  top: 26 + (22 * percent),
                                  child: Transform.scale(
                                    scale: 0.55 + (0.45 * percent),
                                    alignment: Alignment.topLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.topLeft,
                                      child: AnimatedCounterText(
                                        value: displayData.summary.totalSpent,
                                        style: GoogleFonts.outfit(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textBlack,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Filter pill — always visible, top-right
                                Positioned(
                                  right: 20,
                                  top: 14,
                                  child: GestureDetector(
                                    onTap: () => _showFilterSheet(state),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                                          const SizedBox(width: 6),
                                          Text(
                                            _filterLabel(
                                              state.activeFilter,
                                              customStart: state.customStart,
                                              customEnd: state.customEnd,
                                            ),
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.primary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryGrid(displayData.summary),
                          const SizedBox(height: 32),
                          Text(
                            "Category Breakdown",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: _buildCategoryList(displayData.categoryBreakdown),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryGrid(ExpenseBreakdownSummaryEntity summary) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildSummaryCard(title: "Group Share", amount: summary.groupExpenseShare, color: AppColors.primary, icon: Icons.groups_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _buildSummaryCard(title: "Personal", amount: summary.personalExpenseShare, color: AppColors.primaryTeal, icon: Icons.person_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _buildSummaryCard(title: "Non-Group", amount: summary.nonGroupExpenseShare, color: AppColors.iconGrey, icon: Icons.person_outline_rounded)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(AppFormatter.formatCurrency(amount), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textBlack)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryDetailEntity> categories) {
    if (categories.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text("No category data available.", style: GoogleFonts.outfit(color: AppColors.textGrey)),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = categories[index];
          final color = _parseColor(category.color);
          final iconData = IconUtils.getIconFromString(category.icon);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(iconData, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textBlack)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: category.categoryPercentage / 100,
                                backgroundColor: color.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text("${category.categoryPercentage.toStringAsFixed(1)}%", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.iconGrey)),
                        ],
                      ),
                      if (category.limitAmount != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              category.isOverLimit == true
                                  ? "⚠️ Limit exceeded by ₹${((category.spentThisMonth ?? 0) - category.limitAmount!).toStringAsFixed(0)}"
                                  : "₹${(category.remaining ?? 0).toStringAsFixed(0)} left of ₹${category.limitAmount!.toStringAsFixed(0)}",
                              maxLines: 1,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: category.isOverLimit == true ? AppColors.errorRed : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppFormatter.formatCurrency(category.amount), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textBlack)),
                    Text("${category.expenseCount} Trx", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.iconGrey)),
                  ],
                ),
              ],
            ),
          );
        },
        childCount: categories.length,
      ),
    );
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }
}

// ── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterBottomSheet extends StatelessWidget {
  final AnalyticsFilter activeFilter;
  final DateTime? customStart;
  final DateTime? customEnd;
  final void Function(AnalyticsFilter) onFilterSelected;

  const _FilterBottomSheet({
    required this.activeFilter,
    required this.customStart,
    required this.customEnd,
    required this.onFilterSelected,
  });

  static const _options = [
    (AnalyticsFilter.thisWeek,  'This Week',   Icons.view_week_rounded),
    (AnalyticsFilter.lastWeek,  'Last Week',   Icons.history_rounded),
    (AnalyticsFilter.thisMonth, 'This Month',  Icons.calendar_month_rounded),
    (AnalyticsFilter.lastMonth, 'Last Month',  Icons.chevron_left_rounded),
    (AnalyticsFilter.thisYear,  'This Year',   Icons.calendar_today_rounded),
    (AnalyticsFilter.custom,    'Custom Range', Icons.date_range_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Filter by Period",
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textBlack),
          ),
          const SizedBox(height: 4),
          Text(
            "Select a time range to analyse your expenses",
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          // 2-column grid of options
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: _options.map((opt) {
              final (filter, label, icon) = opt;
              final isActive = activeFilter == filter;
              return GestureDetector(
                onTap: () => onFilterSelected(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.borderGreyLight,
                      width: isActive ? 1.5 : 1,
                    ),
                    boxShadow: isActive
                        ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: isActive ? Colors.white : AppColors.iconGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? Colors.white : AppColors.textBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive)
                        const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          // Show selected custom range if applicable
          if (activeFilter == AnalyticsFilter.custom && customStart != null && customEnd != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Selected: ${DateFormat('MMM d, yyyy').format(customStart!)} – ${DateFormat('MMM d, yyyy').format(customEnd!)}",
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
