import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expense_chart_entity.dart';

sealed class PersonalExpensesState extends Equatable {
  const PersonalExpensesState();

  @override
  List<Object?> get props => [];
}

class PersonalExpensesInitial extends PersonalExpensesState {}

class PersonalExpensesLoading extends PersonalExpensesState {}

class PersonalExpensesLoaded extends PersonalExpensesState {
  final PersonalExpensesEntity data;
  final PersonalExpenseChartEntity chartData;

  const PersonalExpensesLoaded({
    required this.data,
    required this.chartData,
  });

  @override
  List<Object?> get props => [data, chartData];
}

class PersonalExpensesError extends PersonalExpensesState {
  final String message;

  const PersonalExpensesError(this.message);

  @override
  List<Object?> get props => [message];
}
