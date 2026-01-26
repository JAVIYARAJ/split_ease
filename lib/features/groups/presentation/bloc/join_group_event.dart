part of 'join_group_bloc.dart';

sealed class JoinGroupEvent extends Equatable {
  const JoinGroupEvent();

  @override
  List<Object> get props => [];
}

final class JoinGroupCodeChanged extends JoinGroupEvent {
  final String code;

  const JoinGroupCodeChanged(this.code);

  @override
  List<Object> get props => [code];
}

final class JoinGroupSubmitted extends JoinGroupEvent {
  const JoinGroupSubmitted();
}
