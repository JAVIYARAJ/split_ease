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
import 'package:intl/intl.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';

class PersonalExpensesPage extends StatefulWidget {
  const PersonalExpensesPage({super.key});

  @override
  State<PersonalExpensesPage> createState() => _PersonalExpensesPageState();
}

class _PersonalExpensesPageState extends State<PersonalExpensesPage> {
  @override
  void initState() {
    super.initState();
    context.read<PersonalExpensesBloc>().add(LoadPersonalExpenses());
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

          final displayData = state is PersonalExpensesLoaded ? state.data : dummyData;

          return Skeletonizer(
            enabled: isLoading,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<PersonalExpensesBloc>().add(LoadPersonalExpenses());
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
                          Text(
                            "Recent Activity",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 16),
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

  Widget _buildHeroCard(PersonalExpensesEntity data) {
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
            child: Skeleton.ignore(child: Icon(Icons.person_rounded, size: 120, color: Colors.white.withValues(alpha: 0.1))),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOTAL PERSONAL SPENT",
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
                      value: data.totalSpent,
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${data.expenseCount} Expenses",
                  style: GoogleFonts.outfit(
                    fontSize: 14, 
                    fontWeight: FontWeight.w500, 
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  NavigationService.pushNamed(
                    AppRoutes.expanseDetail,
                    args: {'expanse_id': expense.id},
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
                              maxLines: 1,
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
}
