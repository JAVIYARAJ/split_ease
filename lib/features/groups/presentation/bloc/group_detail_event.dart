part of 'group_detail_bloc.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupDetails extends GroupDetailEvent {
  final String? groupId;
  final bool hasChanges;

  const LoadGroupDetails({this.groupId, this.hasChanges = false});

  @override
  List<Object?> get props => [groupId, hasChanges];
}

class LoadGroupExpenseHistory extends GroupDetailEvent {
  final String? groupId;
  const LoadGroupExpenseHistory({this.groupId});

  @override
  List<Object?> get props => [groupId];
}
