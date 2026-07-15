import '../../domain/entities/home_dashboard_entity.dart';

class HomeDashboardModel extends HomeDashboardEntity {
  const HomeDashboardModel({
    required super.totalSpend,
    required super.moneyLost,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      totalSpend: DashboardStatModel.fromJson(json['total_spend'] ?? {}),
      moneyLost: DashboardStatModel.fromJson(json['money_lost'] ?? {}),
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
      amount: (json['amount'] ?? 0).toDouble(),
      expenseCount: json['expense_count'] ?? 0,
    );
  }
}
