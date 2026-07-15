import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_breakdown_entity.dart';

enum ExpenseBreakdownStatus { initial, loading, success, failure }

class ExpenseBreakdownState extends Equatable {
  final ExpenseBreakdownStatus status;
  final ExpenseBreakdownEntity? breakdown;
  final String errorMessage;

  const ExpenseBreakdownState({
    this.status = ExpenseBreakdownStatus.initial,
    this.breakdown,
    this.errorMessage = '',
  });

  ExpenseBreakdownState copyWith({
    ExpenseBreakdownStatus? status,
    ExpenseBreakdownEntity? breakdown,
    String? errorMessage,
  }) {
    return ExpenseBreakdownState(
      status: status ?? this.status,
      breakdown: breakdown ?? this.breakdown,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, breakdown, errorMessage];
}
