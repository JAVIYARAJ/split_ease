part of 'group_detail_bloc.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupDetails extends GroupDetailEvent {
  final String groupId;

  const LoadGroupDetails(this.groupId);

  @override
  List<Object> get props => [groupId];
}
