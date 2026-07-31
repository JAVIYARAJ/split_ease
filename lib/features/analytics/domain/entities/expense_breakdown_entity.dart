import 'package:equatable/equatable.dart';

class ExpenseBreakdownSummaryEntity extends Equatable {
  final double totalSpent;
  final double groupExpenseShare;
  final double personalExpenseShare;
  final double nonGroupExpenseShare;

  const ExpenseBreakdownSummaryEntity({
    required this.totalSpent,
    required this.groupExpenseShare,
    required this.personalExpenseShare,
    required this.nonGroupExpenseShare,
  });

  @override
  List<Object?> get props => [
        totalSpent,
        groupExpenseShare,
        personalExpenseShare,
        nonGroupExpenseShare,
      ];
}

class ExpenseBreakdownEntity extends Equatable {
  final ExpenseBreakdownSummaryEntity summary;
  final List<CategoryDetailEntity> categoryBreakdown;
  final List<PaymentMethodDetailEntity> paymentMethodBreakdown;

  const ExpenseBreakdownEntity({
    required this.summary,
    required this.categoryBreakdown,
    this.paymentMethodBreakdown = const [],
  });

  @override
  List<Object?> get props => [summary, categoryBreakdown, paymentMethodBreakdown];
}

class CategoryDetailEntity extends Equatable {
  final String id;
  final String icon;
  final String name;
  final String color;
  final double amount;
  final double categoryPercentage;
  final double budgetPercentage;
  final int expenseCount;
  final double? remaining;
  final double? limitAmount;
  final bool? isOverLimit;
  final double? spentThisMonth;

  const CategoryDetailEntity({
    required this.id,
    required this.icon,
    required this.name,
    required this.color,
    required this.amount,
    required this.categoryPercentage,
    required this.budgetPercentage,
    required this.expenseCount,
    this.remaining,
    this.limitAmount,
    this.isOverLimit,
    this.spentThisMonth,
  });

  @override
  List<Object?> get props => [
        id,
        icon,
        name,
        color,
        amount,
        categoryPercentage,
        budgetPercentage,
        expenseCount,
        remaining,
        limitAmount,
        isOverLimit,
        spentThisMonth,
      ];
}

class PaymentMethodDetailEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int transactionCount;
  final double percentage;

  const PaymentMethodDetailEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.transactionCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        color,
        transactionCount,
        percentage,
      ];
}
