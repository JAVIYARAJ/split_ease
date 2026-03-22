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

  /// Logic Moved from UI: Calculates the total shares assigned.
  double get totalShares => splits.fold(0, (sum, s) => sum + s.shares);

  /// Logic Moved from UI: Calculates the total percentage assigned.
  double get totalPercentage => splits.fold(0, (sum, s) => sum + s.percentage);

  /// Logic Moved from UI: Calculates the current total exact amount assigned.
  double get currentTotalAmount => splits.fold(0, (sum, s) => sum + s.amount);

  /// Logic Moved from UI: Calculates the split amount for a specific user.
  double getMemberAmount(String userId) {
    final split = splits.firstWhere((s) => s.userId == userId, orElse: () => const ExpenseSplit(userId: '', amount: 0, percentage: 0, shares: 0));
    
    if (splitType == SplitType.equal) {
      return splits.isNotEmpty ? totalAmount / splits.length : 0.0;
    } else if (splitType == SplitType.shares) {
      final tShares = totalShares;
      return tShares > 0 ? (totalAmount * split.shares / tShares) : 0;
    } else if (splitType == SplitType.percentage) {
      return (totalAmount * split.percentage / 100);
    } else {
      return split.amount;
    }
  }

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
