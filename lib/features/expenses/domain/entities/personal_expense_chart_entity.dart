import 'package:equatable/equatable.dart';

class PersonalExpenseChartEntity extends Equatable {
  final List<PersonalExpenseChartItemEntity> chart;
  final PersonalExpenseChartSummaryEntity summary;

  const PersonalExpenseChartEntity({
    required this.chart,
    required this.summary,
  });

  @override
  List<Object?> get props => [chart, summary];
}

class PersonalExpenseChartItemEntity extends Equatable {
  final String label;
  final num amount;
  final DateTime sortDate;

  const PersonalExpenseChartItemEntity({
    required this.label,
    required this.amount,
    required this.sortDate,
  });

  @override
  List<Object?> get props => [label, amount, sortDate];
}

class PersonalExpenseChartSummaryEntity extends Equatable {
  final String startDate;
  final String endDate;
  final String groupBy;
  final num totalSpent;
  final num averageSpent;
  final int expenseCount;
  final num lowestExpense;
  final num highestExpense;
  final num? previousPeriodSpent;
  final num? changePercentage;

  const PersonalExpenseChartSummaryEntity({
    required this.startDate,
    required this.endDate,
    required this.groupBy,
    required this.totalSpent,
    required this.averageSpent,
    required this.expenseCount,
    required this.lowestExpense,
    required this.highestExpense,
    this.previousPeriodSpent,
    this.changePercentage,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        groupBy,
        totalSpent,
        averageSpent,
        expenseCount,
        lowestExpense,
        highestExpense,
        previousPeriodSpent,
        changePercentage,
      ];
}
