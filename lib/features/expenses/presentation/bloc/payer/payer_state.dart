part of 'payer_bloc.dart';

class PayerState extends Equatable {
  final List<GroupMemberEntity> members;
  final String? selectedPayerId;

  const PayerState({this.members = const [], this.selectedPayerId});

  /// Logic Moved from UI: Determines the ID to highlight in the list, 
  /// defaulting to the first member if no specific payer is selected.
  String get effectiveSelectedId => selectedPayerId ?? (members.isNotEmpty ? members.first.userId ?? '' : '');

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
