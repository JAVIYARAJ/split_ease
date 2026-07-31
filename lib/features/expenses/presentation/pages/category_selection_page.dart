import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/category_selection/category_selection_cubit.dart';
import 'package:split_ease/features/expenses/presentation/bloc/category_selection/category_selection_state.dart';

class CategorySelectionPage extends StatelessWidget {
  final List<ExpenseCategoryEntity> categories;
  final ExpenseCategoryEntity? selectedCategory;
  final String? lastUsedCategoryId;

  CategorySelectionPage({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.lastUsedCategoryId,
  });

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final sortedCategories = List<ExpenseCategoryEntity>.from(categories)
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return CategorySelectionCubit()..init(sortedCategories, selectedCategory, lastUsedCategoryId);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).ext.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).ext.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Select Category",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).ext.inputFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<CategorySelectionCubit, CategorySelectionState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Icon(Icons.search_rounded, color: Theme.of(context).ext.textTertiary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) => context.read<CategorySelectionCubit>().searchCategories(query),
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).ext.textPrimary),
                            decoration: InputDecoration(
                              hintText: "Search categories...",
                              hintStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: Theme.of(context).ext.textTertiary),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                        if (state.searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context.read<CategorySelectionCubit>().clearSearch();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).ext.border.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded, color: Theme.of(context).ext.textPrimary, size: 14),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<CategorySelectionCubit, CategorySelectionState>(
                builder: (context, state) {
                  if (state.filteredCategories.isEmpty) {
                    return Center(
                      child: Text(
                        "No categories found",
                        style: GoogleFonts.outfit(fontSize: 16, color: Theme.of(context).ext.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: state.filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = state.filteredCategories[index];
                      final isSelected = state.selectedCategory?.id == category.id;

                      Color categoryColor;
                      try {
                        categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
                      } catch (_) {
                        categoryColor = AppColors.primaryTeal;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).ext.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryTeal : Theme.of(context).ext.border.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(IconUtils.getIconFromString(category.icon), color: categoryColor, size: 22),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    category.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: Theme.of(context).ext.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              if (lastUsedCategoryId != null && lastUsedCategoryId == category.id) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    "Last Used",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: categoryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: isSelected 
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal)
                              : Icon(Icons.chevron_right_rounded, color: Theme.of(context).ext.textSecondary, size: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onTap: () {
                            Navigator.pop(context, category);
                          },
                        ),
                      ),
                    );
                  },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
