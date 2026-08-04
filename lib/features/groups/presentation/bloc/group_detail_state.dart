part of 'group_detail_bloc.dart';


class GroupDetailState extends Equatable {
  final GroupDetailStatus status;
  final String? errorMessage;
  final GroupEntity? groupEntity;
  final bool hasChanges;
  final GroupExpenseHistoryEntity? expenseHistory;
  final GroupDetailExpenseStatus expenseStatus;
  final String? expenseErrorMessage;

  const GroupDetailState({
    this.status = GroupDetailStatus.initial,
    this.errorMessage,
    this.groupEntity,
    this.hasChanges = false,
    this.expenseHistory,
    this.expenseStatus = GroupDetailExpenseStatus.initial,
    this.expenseErrorMessage,
  });

  GroupDetailState copyWith({
    GroupDetailStatus? status,
    String? errorMessage,
    GroupEntity? groupEntity,
    bool? hasChanges,
    GroupExpenseHistoryEntity? expenseHistory,
    GroupDetailExpenseStatus? expenseStatus,
    String? expenseErrorMessage,
  }) {
    return GroupDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      groupEntity: groupEntity ?? this.groupEntity,
      hasChanges: hasChanges ?? this.hasChanges,
      expenseHistory: expenseHistory ?? this.expenseHistory,
      expenseStatus: expenseStatus ?? this.expenseStatus,
      expenseErrorMessage: expenseErrorMessage ?? this.expenseErrorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, groupEntity, hasChanges, expenseHistory, expenseStatus, expenseErrorMessage];
}
