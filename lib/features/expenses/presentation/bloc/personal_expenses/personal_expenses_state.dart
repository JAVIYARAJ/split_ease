import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';

sealed class PersonalExpensesState extends Equatable {
  const PersonalExpensesState();

  @override
  List<Object?> get props => [];
}

class PersonalExpensesInitial extends PersonalExpensesState {}

class PersonalExpensesLoading extends PersonalExpensesState {}

class PersonalExpensesLoaded extends PersonalExpensesState {
  final PersonalExpensesEntity data;

  const PersonalExpensesLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class PersonalExpensesError extends PersonalExpensesState {
  final String message;

  const PersonalExpensesError(this.message);

  @override
  List<Object?> get props => [message];
}
