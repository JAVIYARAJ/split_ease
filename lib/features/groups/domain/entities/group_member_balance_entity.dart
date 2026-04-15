import 'package:equatable/equatable.dart';

class GroupMemberBalanceEntity extends Equatable {
  final String userId;
  final String fullName;
  final String? avatar;
  final double balance;

  const GroupMemberBalanceEntity({
    required this.userId,
    required this.fullName,
    this.avatar,
    required this.balance,
  });

  @override
  List<Object?> get props => [userId, fullName, avatar, balance];
}
