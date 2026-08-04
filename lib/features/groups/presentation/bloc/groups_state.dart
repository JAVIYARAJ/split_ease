part of 'groups_bloc.dart';


class GroupsState extends Equatable {
  final GroupsStatus status;
  final List<GroupEntity> groups;
  final String? errorMessage;
  final bool isFabExtended;

  const GroupsState({
    this.status = GroupsStatus.initial,
    this.groups = const [],
    this.errorMessage,
    this.isFabExtended = true,
  });

  GroupsState copyWith({
    GroupsStatus? status,
    List<GroupEntity>? groups,
    String? errorMessage,
    bool? isFabExtended,
  }) {
    return GroupsState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      errorMessage: errorMessage ?? this.errorMessage,
      isFabExtended: isFabExtended ?? this.isFabExtended,
    );
  }

  @override
  List<Object?> get props => [status, groups, errorMessage, isFabExtended];

}
