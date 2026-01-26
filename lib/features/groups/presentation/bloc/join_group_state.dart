part of 'join_group_bloc.dart';

enum JoinGroupStatus { initial, loading, success, failure }

final class JoinGroupState extends Equatable {
  final JoinGroupStatus status;
  final String code;
  final String? errorMessage;
  
  bool get isValid => code.isNotEmpty;

  const JoinGroupState({
    this.status = JoinGroupStatus.initial,
    this.code = '',
    this.errorMessage,
  });

  JoinGroupState copyWith({
    JoinGroupStatus? status,
    String? code,
    String? errorMessage,
  }) {
    return JoinGroupState(
      status: status ?? this.status,
      code: code ?? this.code,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, code, errorMessage];
}
