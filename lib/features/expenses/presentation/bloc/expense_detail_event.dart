import 'package:equatable/equatable.dart';

abstract class ExpenseDetailEvent extends Equatable {
  const ExpenseDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchExpenseDetailEvent extends ExpenseDetailEvent {
  final String expenseId;

  const FetchExpenseDetailEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class DeleteExpenseEvent extends ExpenseDetailEvent {
  final String expenseId;

  const DeleteExpenseEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class RestoreExpenseEvent extends ExpenseDetailEvent {
  final String expenseId;

  const RestoreExpenseEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class MarkExpenseAsChanged extends ExpenseDetailEvent {}

class AddExpenseCommentEvent extends ExpenseDetailEvent {
  final String expenseId;
  final String comment;

  const AddExpenseCommentEvent({required this.expenseId, required this.comment});

  @override
  List<Object> get props => [expenseId, comment];
}
