import 'package:equatable/equatable.dart';

class HomeDashboardEntity extends Equatable {
  final DashboardStatEntity totalSpend;
  final DashboardStatEntity moneyLost;

  const HomeDashboardEntity({
    required this.totalSpend,
    required this.moneyLost,
  });

  @override
  List<Object?> get props => [totalSpend, moneyLost];
}

class DashboardStatEntity extends Equatable {
  final double amount;
  final int expenseCount;

  const DashboardStatEntity({
    required this.amount,
    required this.expenseCount,
  });

  @override
  List<Object?> get props => [amount, expenseCount];
}
