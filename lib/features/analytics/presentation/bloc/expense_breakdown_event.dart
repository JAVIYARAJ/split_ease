import 'package:equatable/equatable.dart';

abstract class ExpenseBreakdownEvent extends Equatable {
  const ExpenseBreakdownEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenseBreakdown extends ExpenseBreakdownEvent {}
