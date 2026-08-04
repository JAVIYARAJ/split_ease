part of 'join_group_bloc.dart';


final class JoinGroupState extends Equatable {
  final JoinGroupStatus status;
  final String code;
  final String? errorMessage;
  final String? joinedGroupId;

  bool get isValid => code.isNotEmpty;

  const JoinGroupState({
    this.status = JoinGroupStatus.initial,
    this.code = '',
    this.errorMessage,
    this.joinedGroupId,
  });

  JoinGroupState copyWith({
    JoinGroupStatus? status,
    String? code,
    String? errorMessage,
    String? joinedGroupId,
  }) {
    return JoinGroupState(
      status: status ?? this.status,
      code: code ?? this.code,
      errorMessage: errorMessage ?? this.errorMessage,
      joinedGroupId: joinedGroupId ?? this.joinedGroupId,
    );
  }

  @override
  List<Object?> get props => [status, code, errorMessage, joinedGroupId];
}
