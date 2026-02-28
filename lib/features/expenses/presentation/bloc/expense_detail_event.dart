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
