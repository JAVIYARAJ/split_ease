import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_formatter.dart';
import 'package:split_ease/core/presentation/widgets/animations/animated_counter_text.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/personal_expenses/personal_expenses_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/personal_expenses/personal_expenses_event.dart';
import 'package:split_ease/features/expenses/presentation/bloc/personal_expenses/personal_expenses_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:flutter/rendering.dart';
import 'package:split_ease/core/presentation/widgets/animations/smooth_animated_fab.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';

import '../../../../core/presentation/widgets/app_back_button.dart';

// ── Filter definition (mirrors AnalyticsFilter) ─────────────────────────────
enum PersonalExpenseFilter {
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

class PersonalExpensesPage extends StatefulWidget {
  const PersonalExpensesPage({super.key});

  @override
  State<PersonalExpensesPage> createState() => _PersonalExpensesPageState();
}

class _PersonalExpensesPageState extends State<PersonalExpensesPage> {
  late final ScrollController _scrollController;
  bool _isFabExtended = true;

  // Filter state
  PersonalExpenseFilter _activeFilter = PersonalExpenseFilter.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    context.read<PersonalExpensesBloc>().add(_buildEvent());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabExtended) {
        setState(() {
          _isFabExtended = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFabExtended) {
        setState(() {
          _isFabExtended = true;
        });
      }
    }
  }

  LoadPersonalExpenses _buildEvent() {
    final dates = _resolveDates(_activeFilter);
    return LoadPersonalExpenses(
      startDate: dates.$1,
      endDate: dates.$2,
    );
  }

  (DateTime?, DateTime?) _resolveDates(PersonalExpenseFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case PersonalExpenseFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return (start, end);
      case PersonalExpenseFilter.lastWeek:
        final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
        final end = startOfThisWeek.subtract(const Duration(days: 1));
        return (end.subtract(const Duration(days: 6)), end);
      case PersonalExpenseFilter.thisMonth:
        return (DateTime(now.year, now.month, 1), now);
      case PersonalExpenseFilter.lastMonth:
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0);
        return (start, end);
      case PersonalExpenseFilter.thisYear:
        return (DateTime(now.year, 1, 1), now);
      case PersonalExpenseFilter.custom:
        return (_customStart, _customEnd);
    }
  }

  String _filterLabel(PersonalExpenseFilter f) {
    switch (f) {
      case PersonalExpenseFilter.thisWeek:  return 'This Week';
      case PersonalExpenseFilter.lastWeek:  return 'Last Week';
      case PersonalExpenseFilter.thisMonth: return 'This Month';
      case PersonalExpenseFilter.lastMonth: return 'Last Month';
      case PersonalExpenseFilter.thisYear:  return 'This Year';
      case PersonalExpenseFilter.custom:
        if (_customStart != null && _customEnd != null) {
          final fmt = DateFormat('MMM d');
          return '${fmt.format(_customStart!)} – ${fmt.format(_customEnd!)}';
        }
        return 'Custom Range';
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PersonalExpenseFilterSheet(
        activeFilter: _activeFilter,
        customStart: _customStart,
        customEnd: _customEnd,
        onFilterSelected: (filter) async {
          Navigator.pop(context);
          if (filter == PersonalExpenseFilter.custom) {
            await _showDateRangePicker();
          } else {
            setState(() => _activeFilter = filter);
            if (mounted) {
              context.read<PersonalExpensesBloc>().add(_buildEvent());
            }
          }
        },
      ),
    );
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surfaceWhite,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _activeFilter = PersonalExpenseFilter.custom;
        _customStart = picked.start;
        _customEnd = picked.end;
      });
      context.read<PersonalExpensesBloc>().add(_buildEvent());
    }
  }

  Future<void> _openAddExpense() async {
    NavigationUtils.handleResult(
      context: context,
      navigation: NavigationService.pushNamed(
        AppRoutes.addExpense,
        args: {
          'origin': ExpenseOrigin.personal,
        },
      ),
      onRefresh: () {
        context.read<PersonalExpensesBloc>().add(LoadPersonalExpenses());
      },
    );
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
          "Personal Expenses",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        leading: AppBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: SmoothAnimatedFAB(
        isExtended: _isFabExtended,
        onPressed: _openAddExpense,
        icon: Icons.add_rounded,
        label: "Add Expense",
        backgroundColor: AppColors.primary,
        heroTag: "personal_expenses_fab",
      ),
      body: BlocBuilder<PersonalExpensesBloc, PersonalExpensesState>(
        builder: (context, state) {
          final isLoading = state is PersonalExpensesLoading || state is PersonalExpensesInitial;
          
          if (state is PersonalExpensesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message, style: GoogleFonts.outfit(color: AppColors.textGrey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<PersonalExpensesBloc>().add(LoadPersonalExpenses()),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          // Dummy data for skeletonizer
          final dummySummary = const PersonalExpenseChartSummaryEntity(
            startDate: "2026-07-01",
            endDate: "2026-07-31",
            groupBy: "day",
            totalSpent: 1500,
            averageSpent: 500,
            expenseCount: 3,
            lowestExpense: 100,
            highestExpense: 900,
            changePercentage: -12.5,
            previousPeriodSpent: 1714,
          );
          final dummyData = PersonalExpensesEntity(
            summary: dummySummary,
            chart: List.generate(7, (index) => PersonalExpenseChartItemEntity(
              label: "0${index + 1} Jul",
              amount: (index + 1) * 100.0,
              sortDate: DateTime.now().subtract(Duration(days: 7 - index)),
            )),
            expenses: List.generate(
              3,
              (index) => PersonalExpenseEntity(
                id: "$index",
                description: "Loading Expense",
                totalAmount: 500,
                expenseDate: DateTime.now().toIso8601String(),
                category: const PersonalExpenseCategoryEntity(
                  id: "0",
                  name: "Category",
                  icon: "shopping_bag",
                  color: "#CCCCCC",
                ),
              ),
            ),
          );

          final displayData = state is PersonalExpensesLoaded ? state.data : dummyData;

          return Skeletonizer(
            enabled: isLoading,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<PersonalExpensesBloc>().add(_buildEvent());
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: AppColors.backgroundWhite,
                    elevation: 0,
                    expandedHeight: 160,
                    collapsedHeight: 64,
                    toolbarHeight: 64,
                    flexibleSpace: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final top = constraints.biggest.height;
                        final percent = ((top - 64) / (160 - 64)).clamp(0.0, 1.0);
                        
                        return ClipRect(
                          child: Container(
                            color: AppColors.backgroundWhite,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 24,
                                  top: 10 + (14 * percent),
                                  child: Text(
                                    "Total Spent",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12 + (2 * percent),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 24,
                                  right: 24,
                                  top: 26 + (22 * percent),
                                  child: Transform.scale(
                                    scale: 0.55 + (0.45 * percent),
                                    alignment: Alignment.topLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.topLeft,
                                      child: AnimatedCounterText(
                                        value: displayData.totalSpent,
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
                                // Filter pill top-right
                                Positioned(
                                  right: 20,
                                  top: 14,
                                  child: GestureDetector(
                                    onTap: _showFilterSheet,
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
                                            _filterLabel(_activeFilter),
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
                          _buildChart(displayData, isLoading: isLoading),
                          const SizedBox(height: 32),
                          Text(
                            "Recent Activity",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildExpenseList(displayData.expenses),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCardPills(PersonalExpensesEntity data, PersonalExpenseChartSummaryEntity summary) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.primaryTeal),
                  const SizedBox(width: 6),
                  Text(
                    "${data.expenseCount} Transactions",
                    style: GoogleFonts.outfit(
                      fontSize: 13, 
                      fontWeight: FontWeight.w600, 
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
            if (summary.changePercentage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: summary.changePercentage! > 0
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      summary.changePercentage! > 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: summary.changePercentage! > 0 ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${summary.changePercentage!.abs().toStringAsFixed(1)}% vs last week",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: summary.changePercentage! > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
  }

  Widget _buildExpenseList(List<PersonalExpenseEntity> expenses) {
    if (expenses.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text("No personal expenses yet.", style: GoogleFonts.outfit(color: AppColors.textGrey)),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final expense = expenses[index];
            final color = expense.category != null ? _parseColor(expense.category!.color) : AppColors.primary;
            final iconData = expense.category != null ? IconUtils.getIconFromString(expense.category!.icon) : Icons.receipt_long_rounded;

            String formattedDate = "";
            try {
              final parsed = DateTime.parse(expense.expenseDate);
              formattedDate = DateFormat('MMM dd').format(parsed);
            } catch (_) {}

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  NavigationUtils.handleResult(
                    context: context,
                    navigation: NavigationService.pushNamed(
                      AppRoutes.expanseDetail,
                      args: {'expanse_id': expense.id},
                    ),
                    onRefresh: () {
                      context.read<PersonalExpensesBloc>().add(LoadPersonalExpenses());
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(iconData, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.description,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBlack,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.iconGrey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppFormatter.formatCurrency(expense.totalAmount),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: expenses.length,
        ),
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

  Widget _buildChart(PersonalExpensesEntity chartData, {bool isLoading = false}) {
    if (chartData.chart.isEmpty) return const SizedBox.shrink();

    double maxAmount = 0;
    for (var item in chartData.chart) {
      if (item.amount.toDouble() > maxAmount) maxAmount = item.amount.toDouble();
    }
    final maxY = maxAmount > 0 ? maxAmount * 1.2 : 100.0;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.15)),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            "${_filterLabel(_activeFilter)} Spending",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
        ),
        Expanded(
          child: Skeleton.replace(
            replace: isLoading,
            replacement: _buildSkeletonChart(),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, animValue, child) {
                return BarChart(
                  BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => AppColors.textBlack,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      AppFormatter.formatCurrency(rod.toY),
                      GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.borderGrey.withValues(alpha: 0.3),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= chartData.chart.length) return const SizedBox.shrink();

                      final itemCount = chartData.chart.length;
                      final interval = (itemCount / 7).ceil();
                      
                      bool shouldShow = false;
                      if (index == itemCount - 1) {
                        shouldShow = true; // Always show the last item
                      } else if (index % interval == 0 && (itemCount - 1 - index) >= interval * 0.8) {
                        shouldShow = true; // Show intervals, but not if they are too close to the last item
                      }

                      if (!shouldShow) {
                        return const SizedBox.shrink();
                      }

                      final item = chartData.chart[index];
                      String labelText = item.label;
                      
                      if (_activeFilter == PersonalExpenseFilter.thisWeek || _activeFilter == PersonalExpenseFilter.lastWeek) {
                        labelText = DateFormat('E').format(item.sortDate);
                      } else if (_activeFilter == PersonalExpenseFilter.thisYear) {
                        labelText = DateFormat('MMM').format(item.sortDate);
                      } else {
                        if (labelText.length > 6) {
                          labelText = labelText.substring(0, 6);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          labelText,
                          style: GoogleFonts.outfit(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: chartData.chart.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final itemCount = chartData.chart.length;
                final barWidth = itemCount > 15 ? 8.0 : (itemCount > 7 ? 16.0 : 32.0);

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.amount.toDouble() * animValue,
                      gradient: LinearGradient(
                        colors: isLoading
                            ? [Colors.grey.shade300, Colors.grey.shade200]
                            : [
                                AppColors.primaryTeal,
                                AppColors.primaryTeal.withValues(alpha: 0.7),
                              ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: barWidth,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: isLoading
                            ? Colors.grey.shade100
                            : AppColors.primaryTeal.withValues(alpha: 0.06),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            swapAnimationDuration: Duration.zero,
          );
        },
      ),
            ),
        ),
      ],
            ),
  );
  }

  Widget _buildSkeletonChart() {
    final heights = [40.0, 80.0, 30.0, 100.0, 60.0, 40.0, 90.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Container(
            width: 32,
            height: heights[index],
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      }),
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────────────────────

class _PersonalExpenseFilterSheet extends StatelessWidget {
  final PersonalExpenseFilter activeFilter;
  final DateTime? customStart;
  final DateTime? customEnd;
  final void Function(PersonalExpenseFilter) onFilterSelected;

  const _PersonalExpenseFilterSheet({
    required this.activeFilter,
    required this.customStart,
    required this.customEnd,
    required this.onFilterSelected,
  });

  static const _options = [
    (PersonalExpenseFilter.thisWeek,  'This Week',    Icons.view_week_rounded),
    (PersonalExpenseFilter.lastWeek,  'Last Week',    Icons.history_rounded),
    (PersonalExpenseFilter.thisMonth, 'This Month',   Icons.calendar_month_rounded),
    (PersonalExpenseFilter.lastMonth, 'Last Month',   Icons.chevron_left_rounded),
    (PersonalExpenseFilter.thisYear,  'This Year',    Icons.calendar_today_rounded),
    (PersonalExpenseFilter.custom,    'Custom Range', Icons.date_range_rounded),
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
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Filter by Period",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Select a time range to filter your expenses",
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          // 2-column grid
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
          // Show selected custom range banner if applicable
          if (activeFilter == PersonalExpenseFilter.custom && customStart != null && customEnd != null) ...[
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
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
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
