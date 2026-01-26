part of 'groups_bloc.dart';

enum GroupsStatus { initial, loading, success, failure }

class GroupsState extends Equatable {
  final GroupsStatus status;
  final List<GroupEntity> groups;
  final String? errorMessage;

  const GroupsState({
    this.status = GroupsStatus.initial,
    this.groups = const [],
    this.errorMessage,
  });

  GroupsState copyWith({
    GroupsStatus? status,
    List<GroupEntity>? groups,
    String? errorMessage,
  }) {
    return GroupsState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, groups, errorMessage];
}
