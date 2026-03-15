import 'package:equatable/equatable.dart';

class FriendExpenseEntity extends Equatable {
  final String expenseId;
  final String? groupId;
  final String type; // "you_lent" | "you_owe" | "you_are_owed"
  final String createdAt;
  final String description;
  final double balanceEffect;
  final String? groupName;
  final String? groupIcon;

  const FriendExpenseEntity({
    required this.expenseId,
    required this.groupId,
    required this.type,
    required this.createdAt,
    required this.description,
    required this.balanceEffect,
    this.groupName,
    this.groupIcon,
  });

  @override
  List<Object?> get props => [
        expenseId,
        groupId,
        type,
        createdAt,
        description,
        balanceEffect,
        groupName,
        groupIcon,
      ];
}
