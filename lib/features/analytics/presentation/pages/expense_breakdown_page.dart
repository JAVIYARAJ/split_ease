import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
    context.read<ExpenseBreakdownBloc>().add(LoadExpenseBreakdown());
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
          final isLoading = state.status == ExpenseBreakdownStatus.loading || state.status == ExpenseBreakdownStatus.initial;
          final breakdown = state.breakdown;

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
                    onPressed: () => context.read<ExpenseBreakdownBloc>().add(LoadExpenseBreakdown()),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          // Provide dummy data for skeletonizer if loading
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

          final displayData = isLoading ? dummyBreakdown : breakdown;

          if (displayData == null) return const SizedBox.shrink();

          return Skeletonizer(
            enabled: isLoading,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ExpenseBreakdownBloc>().add(LoadExpenseBreakdown());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: AppColors.backgroundWhite,
                    elevation: 0,
                    expandedHeight: 120,
                    collapsedHeight: 64,
                    toolbarHeight: 64,
                    flexibleSpace: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final top = constraints.biggest.height;
                        final percent = ((top - 64) / (120 - 64)).clamp(0.0, 1.0);
                        
                        return ClipRect(
                          child: Container(
                            color: AppColors.backgroundWhite,
                            child: Stack(
                              children: [
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
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: "Group Share",
            amount: summary.groupExpenseShare,
            color: AppColors.primary,
            icon: Icons.groups_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: "Personal",
            amount: summary.personalExpenseShare,
            color: AppColors.primaryTeal,
            icon: Icons.person_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: "Non-Group",
            amount: summary.nonGroupExpenseShare,
            color: AppColors.iconGrey,
            icon: Icons.person_outline_rounded,
          ),
        ),
      ],
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
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppFormatter.formatCurrency(amount),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textBlack,
              ),
            ),
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
                        category.name,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
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
                          Text(
                            "${category.categoryPercentage.toStringAsFixed(1)}%",
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.iconGrey),
                          ),
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
                    Text(
                      AppFormatter.formatCurrency(category.amount),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                    Text(
                      "${category.expenseCount} Trx",
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.iconGrey),
                    ),
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
