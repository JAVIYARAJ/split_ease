import 'package:equatable/equatable.dart';

class ExpenseBreakdownEntity extends Equatable {
  final List<CategoryDetailEntity> categoryBreakdown;
  final List<GroupDetailEntity> groupBreakdown;
  final double totalSpent;

  const ExpenseBreakdownEntity({
    required this.categoryBreakdown,
    required this.groupBreakdown,
    required this.totalSpent,
  });

  @override
  List<Object?> get props => [categoryBreakdown, groupBreakdown, totalSpent];
}

class CategoryDetailEntity extends Equatable {
  final String id;
  final String icon;
  final String name;
  final String color;
  final double amount;
  final double percentage;
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
    required this.percentage,
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
        percentage,
        expenseCount,
        remaining,
        limitAmount,
        isOverLimit,
        spentThisMonth,
      ];
}

class GroupDetailEntity extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String? groupIcon;
  final double percentage;
  final int expenseCount;

  const GroupDetailEntity({
    required this.id,
    required this.name,
    required this.amount,
    this.groupIcon,
    required this.percentage,
    required this.expenseCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        groupIcon,
        percentage,
        expenseCount,
      ];
}
