part of 'payer_bloc.dart';

class PayerState extends Equatable {
  final List<GroupMemberEntity> members;
  final String? selectedPayerId;

  const PayerState({this.members = const [], this.selectedPayerId});

  PayerState copyWith({
    List<GroupMemberEntity>? members,
    String? selectedPayerId,
  }) {
    return PayerState(
      members: members ?? this.members,
      selectedPayerId: selectedPayerId ?? this.selectedPayerId,
    );
  }

  @override
  List<Object?> get props => [members, selectedPayerId];
}
