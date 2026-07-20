import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_breakdown_entity.dart';
import 'expense_breakdown_event.dart';

enum ExpenseBreakdownStatus { initial, loading, success, failure }

class ExpenseBreakdownState extends Equatable {
  final ExpenseBreakdownStatus status;
  final ExpenseBreakdownEntity? breakdown;
  final String errorMessage;
  final AnalyticsFilter activeFilter;
  final DateTime? customStart;
  final DateTime? customEnd;

  const ExpenseBreakdownState({
    this.status = ExpenseBreakdownStatus.initial,
    this.breakdown,
    this.errorMessage = '',
    this.activeFilter = AnalyticsFilter.thisMonth,
    this.customStart,
    this.customEnd,
  });

  ExpenseBreakdownState copyWith({
    ExpenseBreakdownStatus? status,
    ExpenseBreakdownEntity? breakdown,
    String? errorMessage,
    AnalyticsFilter? activeFilter,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    return ExpenseBreakdownState(
      status: status ?? this.status,
      breakdown: breakdown ?? this.breakdown,
      errorMessage: errorMessage ?? this.errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
    );
  }

  @override
  List<Object?> get props => [status, breakdown, errorMessage, activeFilter, customStart, customEnd];
}
