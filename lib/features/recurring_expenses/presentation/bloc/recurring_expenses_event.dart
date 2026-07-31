import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_expense_entity.dart';

abstract class RecurringExpensesEvent extends Equatable {
  const RecurringExpensesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecurringExpensesEvent extends RecurringExpensesEvent {}

class FilterRecurringExpensesEvent extends RecurringExpensesEvent {
  final int filterIndex; // 0: All, 1: Active, 2: Paused

  const FilterRecurringExpensesEvent(this.filterIndex);

  @override
  List<Object?> get props => [filterIndex];
}

class AddRecurringExpenseEvent extends RecurringExpensesEvent {
  final RecurringExpenseEntity expense;

  const AddRecurringExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class TogglePauseRecurringExpenseEvent extends RecurringExpensesEvent {
  final String id;

  const TogglePauseRecurringExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteRecurringExpenseEvent extends RecurringExpensesEvent {
  final String id;

  const DeleteRecurringExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}
