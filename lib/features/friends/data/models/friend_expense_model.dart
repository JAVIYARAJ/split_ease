import 'package:split_ease/features/friends/domain/entities/friend_expense_entity.dart';

class FriendExpenseModel extends FriendExpenseEntity {
  const FriendExpenseModel({
    required super.expenseId,
    super.groupId,
    required super.type,
    required super.createdAt,
    required super.description,
    required super.balanceEffect,
    super.groupName,
    super.groupIcon,
  });

  factory FriendExpenseModel.fromJson(Map<String, dynamic> json) {
    return FriendExpenseModel(
      expenseId: json['expense_id'] as String,
      groupId: json['group_id'] as String?,
      type: json['type'] as String,
      createdAt: json['created_at'] as String,
      description: json['description'] as String,
      balanceEffect: (json['balance_effect'] as num).toDouble(),
      groupName: json['group_name'] as String?,
      groupIcon: json['group_icon'] as String?,
    );
  }
}
