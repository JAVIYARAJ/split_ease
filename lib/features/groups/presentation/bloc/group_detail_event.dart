part of 'group_detail_bloc.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupDetails extends GroupDetailEvent {
  final String groupId;
  final GroupEntity? previewGroup;
  final bool hasChanges;

  const LoadGroupDetails(this.groupId, {this.previewGroup, this.hasChanges = false});

  @override
  List<Object> get props => [groupId, if (previewGroup != null) previewGroup!];
}
