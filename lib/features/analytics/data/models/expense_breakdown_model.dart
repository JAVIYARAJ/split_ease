import '../../domain/entities/expense_breakdown_entity.dart';

class ExpenseBreakdownModel extends ExpenseBreakdownEntity {
  const ExpenseBreakdownModel({
    required super.summary,
    required super.categoryBreakdown,
    super.paymentMethodBreakdown = const [],
  });

  factory ExpenseBreakdownModel.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final summary = ExpenseBreakdownSummaryModel.fromJson(summaryJson ?? {});

    final categoryBreakdown = (json['category_breakdown'] as List<dynamic>?)
            ?.map((e) => CategoryDetailModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final paymentMethodBreakdown = (json['payment_method_breakdown'] as List<dynamic>?)
            ?.map((e) => PaymentMethodDetailModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ExpenseBreakdownModel(
      summary: summary,
      categoryBreakdown: categoryBreakdown,
      paymentMethodBreakdown: paymentMethodBreakdown,
    );
  }
}

class ExpenseBreakdownSummaryModel extends ExpenseBreakdownSummaryEntity {
  const ExpenseBreakdownSummaryModel({
    required super.totalSpent,
    required super.groupExpenseShare,
    required super.personalExpenseShare,
    required super.nonGroupExpenseShare,
  });

  factory ExpenseBreakdownSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseBreakdownSummaryModel(
      totalSpent: (json['total_spent'] ?? 0.0).toDouble(),
      groupExpenseShare: (json['group_expense_share'] ?? 0.0).toDouble(),
      personalExpenseShare: (json['personal_expense_share'] ?? 0.0).toDouble(),
      nonGroupExpenseShare: (json['non_group_expense_share'] ?? 0.0).toDouble(),
    );
  }
}

class CategoryDetailModel extends CategoryDetailEntity {
  const CategoryDetailModel({
    required super.id,
    required super.icon,
    required super.name,
    required super.color,
    required super.amount,
    required super.categoryPercentage,
    required super.budgetPercentage,
    required super.expenseCount,
    super.remaining,
    super.limitAmount,
    super.isOverLimit,
    super.spentThisMonth,
  });

  factory CategoryDetailModel.fromJson(Map<String, dynamic> json) {
    return CategoryDetailModel(
      id: json['id'] ?? '',
      icon: json['icon'] ?? 'category',
      name: json['name'] ?? 'Unknown',
      color: json['color'] ?? '#000000',
      amount: (json['amount'] ?? 0).toDouble(),
      categoryPercentage: (json['category_percentage'] ?? 0).toDouble(),
      budgetPercentage: (json['budget_percentage'] ?? 0).toDouble(),
      expenseCount: json['expense_count'] ?? 0,
      remaining: json['remaining'] != null ? (json['remaining'] as num).toDouble() : null,
      limitAmount: json['limit_amount'] != null ? (json['limit_amount'] as num).toDouble() : null,
      isOverLimit: json['is_over_limit'] as bool?,
      spentThisMonth: json['spent_this_month'] != null ? (json['spent_this_month'] as num).toDouble() : null,
    );
  }
}

class PaymentMethodDetailModel extends PaymentMethodDetailEntity {
  const PaymentMethodDetailModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.transactionCount,
    required super.percentage,
  });

  factory PaymentMethodDetailModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      icon: json['icon'] ?? 'payments',
      color: json['color'] ?? '#4CAF50',
      transactionCount: json['transaction_count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}
