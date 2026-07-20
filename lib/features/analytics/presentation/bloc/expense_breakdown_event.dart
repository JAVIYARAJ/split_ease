import 'package:equatable/equatable.dart';

enum AnalyticsFilter {
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

class LoadExpenseBreakdown extends ExpenseBreakdownEvent {
  final AnalyticsFilter filter;
  final DateTime? customStart;
  final DateTime? customEnd;

  const LoadExpenseBreakdown({
    this.filter = AnalyticsFilter.thisMonth,
    this.customStart,
    this.customEnd,
  });

  @override
  List<Object?> get props => [filter, customStart, customEnd];
}

abstract class ExpenseBreakdownEvent extends Equatable {
  const ExpenseBreakdownEvent();

  @override
  List<Object?> get props => [];
}
