import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'category_selection_state.dart';

class CategorySelectionCubit extends Cubit<CategorySelectionState> {
  CategorySelectionCubit()
      : super(const CategorySelectionState(
          allCategories: [],
          filteredCategories: [],
        ));

  void init(List<ExpenseCategoryEntity> categories, ExpenseCategoryEntity? selectedCategory, [String? lastUsedCategoryId]) {
    List<ExpenseCategoryEntity> sortedCategories = List.from(categories);
    
    if (selectedCategory != null) {
      final selectedIndex = sortedCategories.indexWhere((c) => c.id == selectedCategory.id);
      if (selectedIndex != -1) {
        final selected = sortedCategories.removeAt(selectedIndex);
        sortedCategories.insert(0, selected);
      }
    } else if (lastUsedCategoryId != null) {
      final lastUsedIndex = sortedCategories.indexWhere((c) => c.id == lastUsedCategoryId);
      if (lastUsedIndex != -1) {
        final lastUsed = sortedCategories.removeAt(lastUsedIndex);
        sortedCategories.insert(0, lastUsed);
      }
    }

    emit(CategorySelectionState.initial(sortedCategories, selectedCategory));
  }

  void searchCategories(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(
        filteredCategories: state.allCategories,
        searchQuery: query,
      ));
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = state.allCategories
        .where((c) => c.name.toLowerCase().contains(lowerQuery))
        .toList();

    emit(state.copyWith(
      filteredCategories: filtered,
      searchQuery: query,
    ));
  }

  void clearSearch() {
    searchCategories('');
  }
}
