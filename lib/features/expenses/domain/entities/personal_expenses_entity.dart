import 'package:equatable/equatable.dart';

/// Combined entity returned by the single get_personal_expense_rpc
class PersonalExpensesEntity extends Equatable {
  final List<PersonalExpenseEntity> expenses;
  final PersonalExpenseChartSummaryEntity summary;
  final List<PersonalExpenseChartItemEntity> chart;

  const PersonalExpensesEntity({
    required this.expenses,
    required this.summary,
    required this.chart,
  });

  /// Convenience getters kept for backward-compatibility with the UI
  double get totalSpent => summary.totalSpent.toDouble();
  int get expenseCount => summary.expenseCount;

  @override
  List<Object?> get props => [expenses, summary, chart];
}

class PersonalExpenseEntity extends Equatable {
  final String id;
  final String description;
  final String? expenseNote;
  final double totalAmount;
  final String expenseDate;
  final PersonalExpenseCategoryEntity? category;
  final PersonalExpensePaymentMethodEntity? paymentMethod;

  const PersonalExpenseEntity({
    required this.id,
    required this.description,
    this.expenseNote,
    required this.totalAmount,
    required this.expenseDate,
    this.category,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [id, description, expenseNote, totalAmount, expenseDate, category, paymentMethod];
}

class PersonalExpenseCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;

  const PersonalExpenseCategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, icon, color];
}

class PersonalExpensePaymentMethodEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;

  const PersonalExpensePaymentMethodEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, icon, color];
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
  List<Object?> get props => [startDate, endDate, groupBy, totalSpent, averageSpent, expenseCount, lowestExpense, highestExpense, previousPeriodSpent, changePercentage];
}
