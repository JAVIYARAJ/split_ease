import '../../domain/entities/home_dashboard_entity.dart';

class HomeDashboardModel extends HomeDashboardEntity {
  const HomeDashboardModel({
    required super.totalSpend,
    required super.moneyLost,
    required super.recentTransactions,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recent_transactions'] as List<dynamic>? ?? [];
    return HomeDashboardModel(
      totalSpend: DashboardStatModel.fromDynamic(
        json['total_spend'],
        json['total_spend_count'],
      ),
      moneyLost: DashboardStatModel.fromDynamic(
        json['money_lost'],
        json['money_lost_count'],
      ),
      recentTransactions: rawRecent
          .whereType<Map<String, dynamic>>()
          .map((item) => RecentTransactionModel.fromJson(item))
          .toList(),
    );
  }
}

class DashboardStatModel extends DashboardStatEntity {
  const DashboardStatModel({
    required super.amount,
    required super.expenseCount,
  });

  factory DashboardStatModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      expenseCount: (json['expense_count'] as num?)?.toInt() ?? 0,
    );
  }

  factory DashboardStatModel.fromDynamic(dynamic rawValue, [dynamic rawCount]) {
    if (rawValue is Map<String, dynamic>) {
      return DashboardStatModel.fromJson(rawValue);
    }
    final amount = (rawValue as num?)?.toDouble() ?? 0.0;
    final count = (rawCount as num?)?.toInt() ?? 0;
    return DashboardStatModel(
      amount: amount,
      expenseCount: count,
    );
  }
}

class RecentTransactionModel extends RecentTransactionEntity {
  const RecentTransactionModel({
    required super.id,
    required super.title,
    required super.totalAmount,
    required super.expenseDate,
    super.groupId,
    super.groupName,
    super.groupIcon,
    super.paidById,
    super.paidByName,
    super.categoryId,
    super.categoryName,
    super.categoryIcon,
    required super.userShare,
    required super.originType,
    required super.isPaidByMe,
  });

  factory RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionModel(
      id: (json['id'] ?? json['expense_id'])?.toString() ?? '',
      title: (json['title'] ?? json['description'])?.toString() ?? 'Untitled',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      expenseDate: json['expense_date'] != null
          ? DateTime.tryParse(json['expense_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      groupId: json['group_id']?.toString(),
      groupName: json['group_name']?.toString(),
      groupIcon: json['group_icon']?.toString(),
      paidById: json['paid_by_id']?.toString(),
      paidByName: json['paid_by_name']?.toString(),
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name']?.toString(),
      categoryIcon: json['category_icon']?.toString(),
      userShare: (json['user_share'] as num?)?.toDouble() ?? 0.0,
      originType: json['origin_type']?.toString() ?? 'personal',
      isPaidByMe: json['is_paid_by_me'] == true,
    );
  }
}
