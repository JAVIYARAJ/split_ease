import 'package:equatable/equatable.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

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
