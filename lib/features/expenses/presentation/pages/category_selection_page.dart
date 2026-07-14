import 'package:flutter/material.dart';
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
      create: (context) => CategorySelectionCubit()..init(categories, selectedCategory, lastUsedCategoryId),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLightGrey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Select Category",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textBlack),
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
                  color: AppColors.borderGrey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<CategorySelectionCubit, CategorySelectionState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColors.textGrey.withValues(alpha: 0.7), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) => context.read<CategorySelectionCubit>().searchCategories(query),
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textBlack),
                            decoration: InputDecoration(
                              hintText: "Search categories...",
                              hintStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textGrey.withValues(alpha: 0.8)),
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
                                color: AppColors.textGrey.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, color: AppColors.textBlack, size: 14),
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
                        style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textGrey, fontWeight: FontWeight.w500),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryTeal : AppColors.borderGrey.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
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
                                child: Text(
                                  category.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                              : const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onTap: () {
                            Navigator.pop(context, category);
                          },
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
