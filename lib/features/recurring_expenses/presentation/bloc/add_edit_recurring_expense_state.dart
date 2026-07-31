import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import '../../domain/entities/recurring_expense_entity.dart';

class AddEditRecurringExpenseState extends Equatable {
  final String title;
  final String amount;
  final RecurrenceFrequency frequency;
  final int dueDay;
  final bool autoRemind;
  final ExpenseCategoryEntity? selectedCategory;
  final List<ExpenseCategoryEntity> categories;
  final bool isLoadingCategories;

  const AddEditRecurringExpenseState({
    this.title = '',
    this.amount = '',
    this.frequency = RecurrenceFrequency.monthly,
    this.dueDay = 1,
    this.autoRemind = true,
    this.selectedCategory,
    this.categories = const [],
    this.isLoadingCategories = true,
  });

  AddEditRecurringExpenseState copyWith({
    String? title,
    String? amount,
    RecurrenceFrequency? frequency,
    int? dueDay,
    bool? autoRemind,
    ExpenseCategoryEntity? selectedCategory,
    List<ExpenseCategoryEntity>? categories,
    bool? isLoadingCategories,
  }) {
    return AddEditRecurringExpenseState(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      dueDay: dueDay ?? this.dueDay,
      autoRemind: autoRemind ?? this.autoRemind,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
    );
  }

  @override
  List<Object?> get props => [
        title,
        amount,
        frequency,
        dueDay,
        autoRemind,
        selectedCategory,
        categories,
        isLoadingCategories,
      ];
}
