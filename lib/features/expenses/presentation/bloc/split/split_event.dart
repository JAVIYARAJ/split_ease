part of 'split_bloc.dart';

sealed class SplitEvent extends Equatable {
  const SplitEvent();

  @override
  List<Object> get props => [];
}

class InitializeSplitEvent extends SplitEvent {
  final List<GroupMemberEntity> members;
  final SplitType initialSplitType;
  final List<ExpenseSplit> initialSplits;
  final double totalAmount;

  const InitializeSplitEvent({
    required this.members,
    required this.initialSplitType,
    required this.initialSplits,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [members, initialSplitType, initialSplits, totalAmount];
}

class UpdateSplitTypeEvent extends SplitEvent {
  final SplitType splitType;

  const UpdateSplitTypeEvent(this.splitType);

  @override
  List<Object> get props => [splitType];
}

class UpdateSplitAmountEvent extends SplitEvent {
  final String userId;
  final double amount;

  const UpdateSplitAmountEvent({required this.userId, required this.amount});

  @override
  List<Object> get props => [userId, amount];
}

class UpdateSplitPercentageEvent extends SplitEvent {
  final String userId;
  final double percentage;

  const UpdateSplitPercentageEvent({required this.userId, required this.percentage});

  @override
  List<Object> get props => [userId, percentage];
}

class UpdateSplitSharesEvent extends SplitEvent {
  final String userId;
  final double shares;

  const UpdateSplitSharesEvent({required this.userId, required this.shares});

  @override
  List<Object> get props => [userId, shares];
}


class ToggleAllSelectionEvent extends SplitEvent {
  const ToggleAllSelectionEvent();
}

class ToggleMemberSelectionEvent extends SplitEvent {
  final String userId;

  const ToggleMemberSelectionEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
