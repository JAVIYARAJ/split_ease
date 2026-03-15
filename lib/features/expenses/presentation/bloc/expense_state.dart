part of 'expense_bloc.dart';

enum ExpenseStatus { initial, loading, success, failure }

class ExpenseState {
  final ExpenseStatus status;
  final GroupEntity? group;
  final FriendEntity? friend; // For friend-based (non-group) expenses
  final List<GroupEntity> availableGroups; // Groups the user belongs to (for picker)
  final String amount;
  final String description;
  final String? payerId; // ID of the user who paid
  final DateTime? date;
  final SplitType splitType;
  final List<ExpenseSplit> splits;
  final List<GroupMemberEntity> groupMembers;
  final ExpenseStatus groupMembersStatus;
  final List<GroupEntity> commonGroups;
  final ExpenseStatus commonGroupsStatus;
  final String? errorMessage;

  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.group,
    this.friend,
    this.availableGroups = const [],
    this.amount = '',
    this.description = '',
    this.payerId,
    this.date,
    this.splitType = SplitType.equal,
    this.splits = const [],
    this.groupMembers = const [],
    this.groupMembersStatus = ExpenseStatus.initial,
    this.commonGroups = const [],
    this.commonGroupsStatus = ExpenseStatus.initial,
    this.errorMessage,
  });

  ExpenseState copyWith({
    ExpenseStatus? status,
    GroupEntity? group,
    FriendEntity? friend,
    List<GroupEntity>? availableGroups,
    String? amount,
    String? description,
    String? payerId,
    DateTime? date,
    SplitType? splitType,
    List<ExpenseSplit>? splits,
    List<GroupMemberEntity>? groupMembers,
    ExpenseStatus? groupMembersStatus,
    List<GroupEntity>? commonGroups,
    ExpenseStatus? commonGroupsStatus,
    String? errorMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      group: group ?? this.group,
      friend: friend ?? this.friend,
      availableGroups: availableGroups ?? this.availableGroups,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      payerId: payerId ?? this.payerId,
      date: date ?? this.date,
      splitType: splitType ?? this.splitType,
      splits: splits ?? this.splits,
      groupMembers: groupMembers ?? this.groupMembers,
      groupMembersStatus: groupMembersStatus ?? this.groupMembersStatus,
      commonGroups: commonGroups ?? this.commonGroups,
      commonGroupsStatus: commonGroupsStatus ?? this.commonGroupsStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  ExpenseState clearGroup() {
    return ExpenseState(
      status: status,
      friend: friend,
      availableGroups: availableGroups,
      amount: amount,
      description: description,
      payerId: payerId,
      date: date,
      splitType: splitType,
      splits: splits,
      groupMembers: const [],
      groupMembersStatus: ExpenseStatus.initial,
      commonGroups: commonGroups,
      commonGroupsStatus: commonGroupsStatus,
      errorMessage: errorMessage,
    );
  }
}
