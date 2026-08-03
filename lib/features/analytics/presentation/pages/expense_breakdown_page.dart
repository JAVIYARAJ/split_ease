import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
import 'package:split_ease/core/presentation/widgets/app_error_full_screen_dialog.dart';
import 'package:split_ease/core/theme/app_layout.dart';
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).ext.surface,
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
      backgroundColor: Theme.of(context).ext.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).ext.backgroundGrey,
        elevation: 0,
        leadingWidth: AppLayout.appBarLeadingWidth,
        centerTitle: true,
        title: Text(
          "Analytics",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).ext.textPrimary,
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
            return AppErrorFullScreenWidget(
              errorMessage: state.errorMessage,
              onRefresh: () async {
                final bloc = context.read<ExpenseBreakdownBloc>();
                bloc.add(LoadExpenseBreakdown(filter: state.activeFilter));
                final nextState = await bloc.stream.firstWhere(
                  (s) =>
                      s.status != ExpenseBreakdownStatus.loading &&
                      s.status != ExpenseBreakdownStatus.initial,
                );
                return nextState.status == ExpenseBreakdownStatus.success;
              },
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
            paymentMethodBreakdown: List.generate(
              4,
              (index) => PaymentMethodDetailEntity(
                id: "$index",
                name: "Loading Payment",
                icon: "payments",
                color: "#CCCCCC",
                transactionCount: 2,
                percentage: 25,
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
                    backgroundColor: Theme.of(context).ext.backgroundGrey,
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
                            color: Theme.of(context).ext.backgroundGrey,
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
                                      color: Theme.of(context).ext.textSecondary,
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
                                          color: Theme.of(context).ext.textPrimary,
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryGrid(displayData.summary),
                          if (displayData.paymentMethodBreakdown.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            PaymentMethodBreakdownCard(
                              paymentMethods: displayData.paymentMethodBreakdown,
                            ),
                          ],
                          const SizedBox(height: 22),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Category Breakdown",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).ext.textPrimary,
                              ),
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
    final total = summary.totalSpent;
    final groupPct = total > 0 ? (summary.groupExpenseShare / total).clamp(0.0, 1.0) : 0.0;
    final personalPct = total > 0 ? (summary.personalExpenseShare / total).clamp(0.0, 1.0) : 0.0;
    final nonGroupPct = total > 0 ? (summary.nonGroupExpenseShare / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Expense Distribution",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).ext.textPrimary,
                ),
              ),
              Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),

          // Multi-Segment Proportion Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 10,
              width: double.infinity,
              color: Theme.of(context).ext.backgroundGrey,
              child: Row(
                children: [
                  if (groupPct > 0)
                    Flexible(
                      flex: (groupPct * 1000).toInt(),
                      child: Container(color: AppColors.primary),
                    ),
                  if (personalPct > 0)
                    Flexible(
                      flex: (personalPct * 1000).toInt(),
                      child: Container(color: const Color(0xFF00E5FF)),
                    ),
                  if (nonGroupPct > 0)
                    Flexible(
                      flex: (nonGroupPct * 1000).toInt(),
                      child: Container(color: const Color(0xFF7C4DFF)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Distribution Metrics Rows
          _buildDistributionRow(
            title: "Group Share",
            amount: summary.groupExpenseShare,
            percentage: groupPct * 100,
            color: AppColors.primary,
            icon: Icons.groups_rounded,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Theme.of(context).ext.borderLight),
          ),
          _buildDistributionRow(
            title: "Personal",
            amount: summary.personalExpenseShare,
            percentage: personalPct * 100,
            color: const Color(0xFF00E5FF),
            icon: Icons.person_rounded,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Theme.of(context).ext.borderLight),
          ),
          _buildDistributionRow(
            title: "Non-Group",
            amount: summary.nonGroupExpenseShare,
            percentage: nonGroupPct * 100,
            color: const Color(0xFF7C4DFF),
            icon: Icons.person_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionRow({
    required String title,
    required double amount,
    required double percentage,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).ext.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          AppFormatter.formatCurrency(amount),
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).ext.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<CategoryDetailEntity> categories) {
    if (categories.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).ext.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "No Category Data Available",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).ext.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "No expense breakdown found for the selected period. Try picking a different date filter range.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).ext.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
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
              color: Theme.of(context).ext.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
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
                      Text(category.name, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary)),
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
                          Text("${category.categoryPercentage.toStringAsFixed(1)}%", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textTertiary)),
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
                    Text(AppFormatter.formatCurrency(category.amount), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).ext.textPrimary)),
                    Text("${category.expenseCount} Trx", style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).ext.textTertiary)),
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

// ── Payment Method Breakdown Component with ValueNotifier ─────────────────────

class PaymentMethodBreakdownCard extends StatefulWidget {
  final List<PaymentMethodDetailEntity> paymentMethods;

  const PaymentMethodBreakdownCard({
    super.key,
    required this.paymentMethods,
  });

  @override
  State<PaymentMethodBreakdownCard> createState() => _PaymentMethodBreakdownCardState();
}

class _PaymentMethodBreakdownCardState extends State<PaymentMethodBreakdownCard> {
  final ValueNotifier<int> _touchedIndexNotifier = ValueNotifier<int>(-1);

  @override
  void dispose() {
    _touchedIndexNotifier.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (widget.paymentMethods.isEmpty) return const SizedBox.shrink();

    final totalTransactions = widget.paymentMethods.fold<int>(
      0,
      (sum, item) => sum + item.transactionCount,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).ext.border.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment Methods",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).ext.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.donut_large_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Donut Pie Chart + Legend listening to ValueNotifier
          ValueListenableBuilder<int>(
            valueListenable: _touchedIndexNotifier,
            builder: (context, touchedIndex, _) {
              return Column(
                children: [
                  // Donut Pie Chart + Center Text
                  Center(
                    child: SizedBox(
                      height: 190,
                      width: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndexNotifier.value = -1;
                                    return;
                                  }
                                  _touchedIndexNotifier.value = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 3,
                              centerSpaceRadius: 46,
                              sections: widget.paymentMethods.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final isTouched = index == touchedIndex;
                                final radius = isTouched ? 52.0 : 44.0;
                                final color = _parseColor(item.color);

                                return PieChartSectionData(
                                  color: color,
                                  value: item.percentage > 0
                                      ? item.percentage
                                      : (item.transactionCount > 0
                                          ? item.transactionCount.toDouble()
                                          : 1.0),
                                  title: '${item.percentage.toStringAsFixed(0)}%',
                                  radius: radius,
                                  titleStyle: GoogleFonts.outfit(
                                    fontSize: isTouched ? 14 : 12,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).ext.surface,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black38,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // Center statistics in Donut Chart
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$totalTransactions",
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).ext.textPrimary,
                                ),
                              ),
                              Text(
                                "Transactions",
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).ext.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Methods Legend Grid / List
                  Column(
                    children: widget.paymentMethods.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final color = _parseColor(item.color);
                      final iconData = IconUtils.getIconFromString(item.icon);
                      final isTouched = index == touchedIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isTouched
                              ? color.withValues(alpha: 0.1)
                              : Theme.of(context).ext.backgroundGrey,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isTouched
                                ? color
                                : Theme.of(context).ext.border.withValues(alpha: 0.5),
                            width: isTouched ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon inside squircle
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                iconData,
                                color: color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Payment Method Name & Trx count
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).ext.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    "${item.transactionCount} transaction${item.transactionCount == 1 ? '' : 's'}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).ext.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Percentage Badge Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "${item.percentage.toStringAsFixed(1)}%",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
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
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
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
              decoration: BoxDecoration(color: Theme.of(context).ext.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Filter by Period",
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            "Select a time range to analyse your expenses",
            style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary),
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
                    color: isActive ? AppColors.primary : Theme.of(context).ext.backgroundGrey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive ? AppColors.primary : Theme.of(context).ext.border.withValues(alpha: 0.5),
                      width: isActive ? 1.5 : 1,
                    ),
                    boxShadow: isActive
                        ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: isActive ? Colors.white : Theme.of(context).ext.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? Colors.white : Theme.of(context).ext.textPrimary,
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
