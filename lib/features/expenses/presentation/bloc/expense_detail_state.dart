import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';

abstract class ExpenseDetailState extends Equatable {
  const ExpenseDetailState();

  @override
  List<Object?> get props => [];
}

class ExpenseDetailInitial extends ExpenseDetailState {}

class ExpenseDetailLoading extends ExpenseDetailState {}

class ExpenseDetailLoaded extends ExpenseDetailState {
  final ExpenseDetailEntity expenseDetail;

  const ExpenseDetailLoaded(this.expenseDetail);

  @override
  List<Object?> get props => [expenseDetail];
}

class ExpenseDetailError extends ExpenseDetailState {
  final String message;

  const ExpenseDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExpenseDeleteLoading extends ExpenseDetailState {}

class ExpenseDeleted extends ExpenseDetailState {}

class ExpenseDeleteError extends ExpenseDetailState {
  final String message;

  const ExpenseDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
