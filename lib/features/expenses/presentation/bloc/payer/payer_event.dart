part of 'payer_bloc.dart';

sealed class PayerEvent extends Equatable {
  const PayerEvent();

  @override
  List<Object> get props => [];
}

class LoadPayerEvent extends PayerEvent {
  final GroupEntity group;
  final String? initialPayerId;

  const LoadPayerEvent({required this.group, this.initialPayerId});

  @override
  List<Object> get props => [group, if (initialPayerId != null) initialPayerId!];
}

class SelectPayerEvent extends PayerEvent {
  final String payerId;

  const SelectPayerEvent(this.payerId);

  @override
  List<Object> get props => [payerId];
}
