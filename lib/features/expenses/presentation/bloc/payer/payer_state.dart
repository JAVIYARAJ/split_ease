part of 'payer_bloc.dart';

class PayerState extends Equatable {
  final GroupEntity? group;
  final String? selectedPayerId;

  const PayerState({this.group, this.selectedPayerId});

  PayerState copyWith({
    GroupEntity? group,
    String? selectedPayerId,
  }) {
    return PayerState(
      group: group ?? this.group,
      selectedPayerId: selectedPayerId ?? this.selectedPayerId,
    );
  }

  @override
  List<Object?> get props => [group, selectedPayerId];
}
