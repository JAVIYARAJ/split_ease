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
import 'package:split_ease/features/expenses/domain/entities/personal_expense_chart_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:flutter/rendering.dart';
import 'package:split_ease/core/presentation/widgets/animations/smooth_animated_fab.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';

class PersonalExpensesPage extends StatefulWidget {
  const PersonalExpensesPage({super.key});

  @override
  State<PersonalExpensesPage> createState() => _PersonalExpensesPageState();
}

class _PersonalExpensesPageState extends State<PersonalExpensesPage> {
  late final ScrollController _scrollController;
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    context.read<PersonalExpensesBloc>().add(LoadPersonalExpenses());
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
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
          final dummyData = PersonalExpensesEntity(
            totalSpent: 1500,
            expenseCount: 3,
            expenses: List.generate(
              3,
              (index) => PersonalExpenseEntity(
                id: "$index",
                description: "Loading Expense",
                totalAmount: 500,
                createdAt: DateTime.now().toIso8601String(),
                category: const PersonalExpenseCategoryEntity(
                  id: "0",
                  name: "Category",
                  icon: "shopping_bag",
                  color: "#CCCCCC",
                ),
              ),
            ),
          );

          final dummyChartData = PersonalExpenseChartEntity(
            summary: const PersonalExpenseChartSummaryEntity(
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
            ),
            chart: List.generate(7, (index) => PersonalExpenseChartItemEntity(
              label: "0${index + 1} Jul",
              amount: (index + 1) * 100.0,
              sortDate: DateTime.now().subtract(Duration(days: 7 - index)),
            )),
          );

          final displayData = state is PersonalExpensesLoaded ? state.data : dummyData;
          final displayChartData = state is PersonalExpensesLoaded ? state.chartData : dummyChartData;

          return Skeletonizer(
            enabled: isLoading,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<PersonalExpensesBloc>().add(LoadPersonalExpenses());
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
                                Positioned(
                                  left: 24,
                                  right: 24,
                                  top: 112 + (20 * (1 - percent)),
                                  child: Opacity(
                                    opacity: percent,
                                    child: _buildHeroCardPills(displayData, displayChartData.summary),
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
                          _buildChart(displayChartData, isLoading: isLoading),
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
              final parsed = DateTime.parse(expense.createdAt);
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

  Widget _buildChart(PersonalExpenseChartEntity chartData, {bool isLoading = false}) {
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
            "This Week's Spending",
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

                      final item = chartData.chart[index];
                      final dayName = DateFormat('E').format(item.sortDate);

                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          dayName,
                          style: GoogleFonts.outfit(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
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
                      width: 32,
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
