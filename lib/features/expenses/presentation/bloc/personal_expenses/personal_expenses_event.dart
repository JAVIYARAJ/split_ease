import 'package:equatable/equatable.dart';

sealed class PersonalExpensesEvent extends Equatable {
  const PersonalExpensesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPersonalExpenses extends PersonalExpensesEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final String? paymentMethodId;

  const LoadPersonalExpenses({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.paymentMethodId,
  });

  @override
  List<Object?> get props => [startDate, endDate, categoryId, paymentMethodId];
}
