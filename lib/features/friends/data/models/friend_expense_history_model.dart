import 'package:split_ease/features/friends/data/models/friend_expense_model.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_history_entity.dart';

class FriendDetailUserModel extends FriendDetailUserEntity {
  const FriendDetailUserModel({
    required super.id,
    required super.avatar,
    required super.email,
    required super.fullName,
  });

  factory FriendDetailUserModel.fromJson(Map<String, dynamic> json) {
    return FriendDetailUserModel(
      id: json['id'] as String?,
      avatar: json['avtar'] as String?, // Typo in given JSON 'avtar'
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
    );
  }
}

class FriendGroupBreakdownModel extends FriendGroupBreakdownEntity {
  const FriendGroupBreakdownModel({
    required super.balance,
    required super.groupId,
    super.groupIcon,
    required super.groupName,
  });

  factory FriendGroupBreakdownModel.fromJson(Map<String, dynamic> json) {
    return FriendGroupBreakdownModel(
      balance: (json['balance'] as num).toDouble(),
      groupId: json['group_id'] as String,
      groupIcon: json['group_icon'] as String?,
      groupName: json['group_name'] as String,
    );
  }
}

class FriendExpenseHistoryModel extends FriendExpenseHistoryEntity {
  const FriendExpenseHistoryModel({
    required super.user,
    required super.status,
    required super.expenses,
    required super.groupBreakdown,
    required super.overallBalance,
  });

  factory FriendExpenseHistoryModel.fromJson(Map<String, dynamic> json) {
    final expensesList = json['expense_history'] != null
        ? (json['expense_history'] as List<dynamic>)
            .map((e) => FriendExpenseModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : null;

    final breakdownList = json['group_breakdown'] != null
        ? (json['group_breakdown'] as List<dynamic>)
            .map((e) => FriendGroupBreakdownModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <FriendGroupBreakdownModel>[];

    return FriendExpenseHistoryModel(
      user: FriendDetailUserModel.fromJson(json['user'] as Map<String, dynamic>),
      status: json['status'] as String,
      expenses: expensesList,
      groupBreakdown: breakdownList,
      overallBalance: (json['overall_balance'] as num).toDouble(),
    );
  }
}
