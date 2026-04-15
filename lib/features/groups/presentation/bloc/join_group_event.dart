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

final class JoinGroupQrScanned extends JoinGroupEvent {
  final String qrCode;

  const JoinGroupQrScanned(this.qrCode);

  @override
  List<Object> get props => [qrCode];
}

final class JoinGroupSubmitted extends JoinGroupEvent {
  const JoinGroupSubmitted();
}
