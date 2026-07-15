import '../../domain/entities/expense_breakdown_entity.dart';

class ExpenseBreakdownModel extends ExpenseBreakdownEntity {
  const ExpenseBreakdownModel({
    required super.categoryBreakdown,
    required super.groupBreakdown,
    required super.totalSpent,
  });

  factory ExpenseBreakdownModel.fromJson(Map<String, dynamic> json) {
    final categoryBreakdown = (json['category_breakdown'] as List<dynamic>?)
            ?.map((e) => CategoryDetailModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final groupBreakdown = (json['group_breakdown'] as List<dynamic>?)
            ?.map((e) => GroupDetailModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    
    // We compute totalSpent dynamically based on categories, 
    // or groups (both should logically sum up to the same total)
    final totalSpent = categoryBreakdown.fold<double>(0, (sum, item) => sum + item.amount);

    return ExpenseBreakdownModel(
      categoryBreakdown: categoryBreakdown,
      groupBreakdown: groupBreakdown,
      totalSpent: totalSpent,
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
    required super.percentage,
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
      percentage: (json['percentage'] ?? 0).toDouble(),
      expenseCount: json['expense_count'] ?? 0,
      remaining: json['remaining'] != null ? (json['remaining'] as num).toDouble() : null,
      limitAmount: json['limit_amount'] != null ? (json['limit_amount'] as num).toDouble() : null,
      isOverLimit: json['is_over_limit'] as bool?,
      spentThisMonth: json['spent_this_month'] != null ? (json['spent_this_month'] as num).toDouble() : null,
    );
  }
}

class GroupDetailModel extends GroupDetailEntity {
  const GroupDetailModel({
    required super.id,
    required super.name,
    required super.amount,
    super.groupIcon,
    required super.percentage,
    required super.expenseCount,
  });

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    return GroupDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      amount: (json['amount'] ?? 0).toDouble(),
      groupIcon: json['group_icon'],
      percentage: (json['percentage'] ?? 0).toDouble(),
      expenseCount: json['expense_count'] ?? 0,
    );
  }
}
