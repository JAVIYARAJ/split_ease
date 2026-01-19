import 'group_balance_detail.dart';

class GroupEntity {
  final String id;
  final String name;
  final String? imageUrl;
  final double totalBalance; // Positive: you are owed, Negative: you owe
  final List<GroupBalanceDetail> balanceDetails;

  const GroupEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.totalBalance,
    required this.balanceDetails,
  });
}
