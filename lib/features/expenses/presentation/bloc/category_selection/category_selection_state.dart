import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';

class CategorySelectionState extends Equatable {
  final List<ExpenseCategoryEntity> allCategories;
  final List<ExpenseCategoryEntity> filteredCategories;
  final ExpenseCategoryEntity? selectedCategory;
  final String searchQuery;

  const CategorySelectionState({
    required this.allCategories,
    required this.filteredCategories,
    this.selectedCategory,
    this.searchQuery = '',
  });

  factory CategorySelectionState.initial(
      List<ExpenseCategoryEntity> categories, ExpenseCategoryEntity? selectedCategory) {
    return CategorySelectionState(
      allCategories: categories,
      filteredCategories: categories,
      selectedCategory: selectedCategory,
    );
  }

  CategorySelectionState copyWith({
    List<ExpenseCategoryEntity>? allCategories,
    List<ExpenseCategoryEntity>? filteredCategories,
    ExpenseCategoryEntity? selectedCategory,
    String? searchQuery,
  }) {
    return CategorySelectionState(
      allCategories: allCategories ?? this.allCategories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allCategories, filteredCategories, selectedCategory, searchQuery];
}
