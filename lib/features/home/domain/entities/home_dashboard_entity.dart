import 'package:equatable/equatable.dart';

class HomeDashboardEntity extends Equatable {
  final DashboardStatEntity totalSpend;
  final DashboardStatEntity moneyLost;
  final List<RecentTransactionEntity> recentTransactions;

  const HomeDashboardEntity({
    required this.totalSpend,
    required this.moneyLost,
    this.recentTransactions = const [],
  });

  @override
  List<Object?> get props => [totalSpend, moneyLost, recentTransactions];
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

class RecentTransactionEntity extends Equatable {
  final String id;
  final String title;
  final double totalAmount;
  final DateTime expenseDate;
  final String? groupId;
  final String? groupName;
  final String? groupIcon;
  final String? paidById;
  final String? paidByName;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final double userShare;
  final String originType; // 'group', 'friend', 'personal'
  final bool isPaidByMe;

  const RecentTransactionEntity({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.expenseDate,
    this.groupId,
    this.groupName,
    this.groupIcon,
    this.paidById,
    this.paidByName,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    required this.userShare,
    required this.originType,
    required this.isPaidByMe,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        totalAmount,
        expenseDate,
        groupId,
        groupName,
        groupIcon,
        paidById,
        paidByName,
        categoryId,
        categoryName,
        categoryIcon,
        userShare,
        originType,
        isPaidByMe,
      ];
}
