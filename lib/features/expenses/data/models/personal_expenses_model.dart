import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';

class PersonalExpensesModel extends PersonalExpensesEntity {
  const PersonalExpensesModel({
    required super.expenses,
    required super.summary,
    required super.chart,
  });

  factory PersonalExpensesModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpensesModel(
      summary: PersonalExpenseChartSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
      chart: (json['chart'] as List<dynamic>? ?? [])
          .map((item) => PersonalExpenseChartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      expenses: (json['expenses'] as List<dynamic>? ?? [])
          .map((e) => PersonalExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PersonalExpenseModel extends PersonalExpenseEntity {
  const PersonalExpenseModel({
    required super.id,
    required super.description,
    super.expenseNote,
    required super.totalAmount,
    required super.expenseDate,
    super.category,
    super.paymentMethod,
  });

  factory PersonalExpenseModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpenseModel(
      id: json['id'] as String,
      description: json['description'] as String,
      expenseNote: json['expense_note'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      expenseDate: json['expense_date'] as String? ?? '',
      category: json['category'] != null
          ? PersonalExpenseCategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      paymentMethod: json['payment_method'] != null
          ? PersonalExpensePaymentMethodModel.fromJson(json['payment_method'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PersonalExpenseCategoryModel extends PersonalExpenseCategoryEntity {
  const PersonalExpenseCategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
  });

  factory PersonalExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpenseCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}

class PersonalExpensePaymentMethodModel extends PersonalExpensePaymentMethodEntity {
  const PersonalExpensePaymentMethodModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
  });

  factory PersonalExpensePaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpensePaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
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
      label: json['label'] as String? ?? '',
      amount: (json['amount'] as num?) ?? 0,
      sortDate: json['sort_date'] != null
          ? DateTime.parse(json['sort_date'] as String)
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
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      groupBy: json['group_by'] as String? ?? '',
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
