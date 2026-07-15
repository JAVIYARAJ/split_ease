import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_formatter.dart';
import 'package:split_ease/core/presentation/widgets/animations/animated_counter_text.dart';
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
  int _selectedTab = 0; // 0 for Category, 1 for Group

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack, size: 20),
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
            totalSpent: 1500,
            categoryBreakdown: List.generate(
              5,
              (index) => CategoryDetailEntity(
                id: "$index",
                icon: "category",
                name: "Loading Category",
                color: "#CCCCCC",
                amount: 300,
                percentage: 20,
                expenseCount: 2,
              ),
            ),
            groupBreakdown: List.generate(
              5,
              (index) => GroupDetailEntity(
                id: "$index",
                name: "Loading Group",
                amount: 300,
                percentage: 20,
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroCard(displayData),
                          const SizedBox(height: 32),
                          _buildTabToggle(),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: _selectedTab == 0
                        ? _buildCategoryList(displayData.categoryBreakdown)
                        : _buildGroupList(displayData.groupBreakdown),
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

  Widget _buildHeroCard(ExpenseBreakdownEntity breakdown) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -20,
            child: Skeleton.ignore(child: Icon(Icons.analytics_rounded, size: 120, color: Colors.white.withValues(alpha: 0.1))),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOTAL EXPENSES",
                  style: GoogleFonts.outfit(
                    fontSize: 11, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white.withValues(alpha: 0.6), 
                    letterSpacing: 1.2
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AnimatedCounterText(
                      value: breakdown.totalSpent,
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.borderGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: _selectedTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w600,
                        color: _selectedTab == 0 ? AppColors.textBlack : AppColors.textGrey,
                      ),
                      child: const Text("Categories"),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w600,
                        color: _selectedTab == 1 ? AppColors.textBlack : AppColors.textGrey,
                      ),
                      child: const Text("Groups"),
                    ),
                  ),
                ),
              ),
            ],
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
          final iconData = _parseIcon(category.icon);

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
                                value: category.percentage / 100,
                                backgroundColor: color.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${category.percentage.toStringAsFixed(1)}%",
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

  Widget _buildGroupList(List<GroupDetailEntity> groups) {
    if (groups.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text("No group data available.", style: GoogleFonts.outfit(color: AppColors.textGrey)),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final group = groups[index];

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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    image: group.groupIcon != null && group.groupIcon!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(group.groupIcon!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: group.groupIcon == null || group.groupIcon!.isEmpty
                      ? Icon(Icons.groups_rounded, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
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
                                value: group.percentage / 100,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${group.percentage.toStringAsFixed(1)}%",
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.iconGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatter.formatCurrency(group.amount),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                    Text(
                      "${group.expenseCount} Trx",
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.iconGrey),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        childCount: groups.length,
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

  IconData _parseIcon(String iconString) {
    switch (iconString) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'local_movies':
        return Icons.local_movies_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
