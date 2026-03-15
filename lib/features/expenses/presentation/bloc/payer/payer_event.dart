part of 'payer_bloc.dart';

sealed class PayerEvent extends Equatable {
  const PayerEvent();

  @override
  List<Object> get props => [];
}

class LoadPayerEvent extends PayerEvent {
  final List<GroupMemberEntity> members;
  final String? initialPayerId;

  const LoadPayerEvent({required this.members, this.initialPayerId});

  @override
  List<Object> get props => [members, if (initialPayerId != null) initialPayerId!];
}

class SelectPayerEvent extends PayerEvent {
  final String payerId;

  const SelectPayerEvent(this.payerId);

  @override
  List<Object> get props => [payerId];
}
