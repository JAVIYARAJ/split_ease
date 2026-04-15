import 'package:equatable/equatable.dart';
import 'package:split_ease/features/groups/domain/entities/group_expense_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_balance_entity.dart';

class GroupExpenseHistoryEntity extends Equatable {
  final List<GroupExpenseEntity>? expenses;
  final List<GroupMemberBalanceEntity>? memberBalances;
  final double overallBalance;
  final bool? youAreOwed;

  const GroupExpenseHistoryEntity({
    required this.expenses,
    required this.memberBalances,
    required this.overallBalance,
    required this.youAreOwed,
  });

  @override
  List<Object?> get props => [expenses, memberBalances, overallBalance, youAreOwed];
}
