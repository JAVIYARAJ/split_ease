import 'package:split_ease/features/expenses/domain/entities/personal_expense_chart_entity.dart';

class PersonalExpenseChartModel extends PersonalExpenseChartEntity {
  const PersonalExpenseChartModel({
    required super.chart,
    required super.summary,
  });

  factory PersonalExpenseChartModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpenseChartModel(
      chart: (json['chart'] as List<dynamic>?)
              ?.map((item) => PersonalExpenseChartItemModel.fromJson(item))
              .toList() ??
          [],
      summary: PersonalExpenseChartSummaryModel.fromJson(json['summary'] ?? {}),
    );
  }
}

class PersonalExpenseChartItemModel extends PersonalExpenseChartItemEntity {
  const PersonalExpenseChartItemModel({
    required super.label,
    required super.amount,
    required super.sortDate,
  });

  factory PersonalExpenseChartItemModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpenseChartItemModel(
      label: json['label'] ?? '',
      amount: (json['amount'] as num?) ?? 0,
      sortDate: json['sort_date'] != null 
          ? DateTime.parse(json['sort_date']) 
          : DateTime.now(),
    );
  }
}

class PersonalExpenseChartSummaryModel extends PersonalExpenseChartSummaryEntity {
  const PersonalExpenseChartSummaryModel({
    required super.startDate,
    required super.endDate,
    required super.groupBy,
    required super.totalSpent,
    required super.averageSpent,
    required super.expenseCount,
    required super.lowestExpense,
    required super.highestExpense,
    super.previousPeriodSpent,
    super.changePercentage,
  });

  factory PersonalExpenseChartSummaryModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpenseChartSummaryModel(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      groupBy: json['group_by'] ?? '',
      totalSpent: (json['total_spent'] as num?) ?? 0,
      averageSpent: (json['average_spent'] as num?) ?? 0,
      expenseCount: (json['expense_count'] as num?)?.toInt() ?? 0,
      lowestExpense: (json['lowest_expense'] as num?) ?? 0,
      highestExpense: (json['highest_expense'] as num?) ?? 0,
      previousPeriodSpent: json['previous_period_spent'] as num?,
      changePercentage: json['change_percentage'] as num?,
    );
  }
}
