import 'package:equatable/equatable.dart';

class GroupBalancePreviewEntity extends Equatable {
  final double? balance;
  final String? fullName;

  const GroupBalancePreviewEntity({
    this.balance,
    this.fullName,
  });

  @override
  List<Object?> get props => [balance, fullName];
}
