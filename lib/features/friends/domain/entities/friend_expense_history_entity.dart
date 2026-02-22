import 'package:equatable/equatable.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_entity.dart';

class FriendDetailUserEntity extends Equatable {
  final String id;
  final String avatar;
  final String email;
  final String fullName;

  const FriendDetailUserEntity({
    required this.id,
    required this.avatar,
    required this.email,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, avatar, email, fullName];
}

class FriendGroupBreakdownEntity extends Equatable {
  final double balance;
  final String groupId;
  final String? groupIcon;
  final String groupName;

  const FriendGroupBreakdownEntity({
    required this.balance,
    required this.groupId,
    this.groupIcon,
    required this.groupName,
  });

  @override
  List<Object?> get props => [balance, groupId, groupIcon, groupName];
}

class FriendExpenseHistoryEntity extends Equatable {
  final FriendDetailUserEntity user;
  final String status;
  final List<FriendExpenseEntity>? expenses;
  final List<FriendGroupBreakdownEntity> groupBreakdown;
  final double overallBalance;

  const FriendExpenseHistoryEntity({
    required this.user,
    required this.status,
    required this.expenses,
    required this.groupBreakdown,
    required this.overallBalance,
  });

  @override
  List<Object?> get props => [user, status, expenses, groupBreakdown, overallBalance];
}
