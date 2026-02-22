part of 'split_bloc.dart';

class SplitState extends Equatable {
  final List<GroupMemberEntity> members;
  final SplitType splitType;
  final List<ExpenseSplit> splits;
  final double totalAmount;

  const SplitState({
    this.members = const [],
    this.splitType = SplitType.equal,
    this.splits = const [],
    this.totalAmount = 0.0,
  });

  SplitState copyWith({
    List<GroupMemberEntity>? members,
    SplitType? splitType,
    List<ExpenseSplit>? splits,
    double? totalAmount,
  }) {
    return SplitState(
      members: members ?? this.members,
      splitType: splitType ?? this.splitType,
      splits: splits ?? this.splits,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object> get props => [members, splitType, splits, totalAmount];
}
