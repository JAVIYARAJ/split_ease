import 'package:split_ease/features/groups/domain/entities/group_expense_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_expense_history_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_balance_entity.dart';

class GroupExpenseModel extends GroupExpenseEntity {
  const GroupExpenseModel({
    required super.expenseId,
    required super.type,
    required super.paidBy,
    required super.paidByName,
    required super.createdAt,
    required super.description,
    required super.totalAmount,
    required super.yourBalanceEffect,
  });

  factory GroupExpenseModel.fromJson(Map<String, dynamic> json) {
    return GroupExpenseModel(
      expenseId: json['expense_id'] as String,
      type: json['type'] as String,
      paidBy: json['paid_by'] as String,
      paidByName: json['paid_by_name'] as String,
      createdAt: json['created_at'] as String,
      description: json['description'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      yourBalanceEffect: (json['your_balance_effect'] as num).toDouble(),
    );
  }
}

class GroupMemberBalanceModel extends GroupMemberBalanceEntity {
  const GroupMemberBalanceModel({
    required super.userId,
    required super.fullName,
    super.avatar,
    required super.balance,
  });

  factory GroupMemberBalanceModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberBalanceModel(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      avatar: json['avtar'] as String?,
      balance: (json['balance'] as num).toDouble(),
    );
  }
}

class GroupExpenseHistoryModel extends GroupExpenseHistoryEntity {
  const GroupExpenseHistoryModel({
    required super.expenses,
    required super.memberBalances,
    required super.overallBalance,
    required super.youAreOwed,
  });

  factory GroupExpenseHistoryModel.fromJson(Map<String, dynamic> json) {
    final expensesList = json['expenses'] != null ? (json['expenses'] as List<dynamic>)
        .map((e) => GroupExpenseModel.fromJson(e as Map<String, dynamic>))
        .toList() : null;

    final memberBalancesList = json['member_balances'] != null ?  (json['member_balances'] as List<dynamic>)
        .map((e) => GroupMemberBalanceModel.fromJson(e as Map<String, dynamic>))
        .toList(): null;

    return GroupExpenseHistoryModel(
      expenses: expensesList,
      memberBalances: memberBalancesList,
      overallBalance: (json['overall_balance'] as num).toDouble(),
      youAreOwed: json['you_are_owed'] as bool,
    );
  }
}
