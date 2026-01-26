part of 'group_detail_bloc.dart';

enum GroupDetailStatus { loading, success, failure }

class GroupDetailState extends Equatable {
  final GroupDetailStatus status;
  final String? errorMessage;
  final GroupEntity? groupEntity;
  // Add more fields here as needed, e.g., Group entity, List<Transaction>

  const GroupDetailState({
    this.status = GroupDetailStatus.loading,
    this.errorMessage,
    this.groupEntity
  });

  GroupDetailState copyWith({
    GroupDetailStatus? status,
    String? errorMessage,
    GroupEntity? groupEntity
  }) {
    return GroupDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      groupEntity: groupEntity ?? this.groupEntity,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage,groupEntity];
}
