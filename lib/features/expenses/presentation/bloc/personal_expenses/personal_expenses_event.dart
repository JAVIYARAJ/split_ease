import 'package:equatable/equatable.dart';

sealed class PersonalExpensesEvent extends Equatable {
  const PersonalExpensesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPersonalExpenses extends PersonalExpensesEvent {}
