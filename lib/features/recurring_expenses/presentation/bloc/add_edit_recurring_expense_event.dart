import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import '../../domain/entities/recurring_expense_entity.dart';

abstract class AddEditRecurringExpenseEvent extends Equatable {
  const AddEditRecurringExpenseEvent();

  @override
  List<Object?> get props => [];
}

class AddEditRecurringExpenseInitialized extends AddEditRecurringExpenseEvent {
  final RecurringExpenseEntity? existing;

  const AddEditRecurringExpenseInitialized(this.existing);

  @override
  List<Object?> get props => [existing];
}

class AddEditRecurringExpenseTitleChanged extends AddEditRecurringExpenseEvent {
  final String title;

  const AddEditRecurringExpenseTitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class AddEditRecurringExpenseAmountChanged extends AddEditRecurringExpenseEvent {
  final String amount;

  const AddEditRecurringExpenseAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

class AddEditRecurringExpenseFrequencyChanged extends AddEditRecurringExpenseEvent {
  final RecurrenceFrequency frequency;

  const AddEditRecurringExpenseFrequencyChanged(this.frequency);

  @override
  List<Object?> get props => [frequency];
}

class AddEditRecurringExpenseDueDayChanged extends AddEditRecurringExpenseEvent {
  final int dueDay;

  const AddEditRecurringExpenseDueDayChanged(this.dueDay);

  @override
  List<Object?> get props => [dueDay];
}

class AddEditRecurringExpenseRemindToggled extends AddEditRecurringExpenseEvent {
  final bool remind;

  const AddEditRecurringExpenseRemindToggled(this.remind);

  @override
  List<Object?> get props => [remind];
}

class AddEditRecurringExpenseCategoryChanged extends AddEditRecurringExpenseEvent {
  final ExpenseCategoryEntity category;

  const AddEditRecurringExpenseCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}
