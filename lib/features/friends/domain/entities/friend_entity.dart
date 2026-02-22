class FriendGroupBreakdownEntity {
  final double balance;
  final String groupId;
  final String groupName;

  const FriendGroupBreakdownEntity({
    required this.balance,
    required this.groupId,
    required this.groupName,
  });
}

class FriendEntity {
  final String id;
  final String name;
  final String? imageUrl;
  final double overallBalance;
  final double nonGroupBalance;
  final int totalBalanceGroups;
  final String status;
  final List<FriendGroupBreakdownEntity> groupBreakdown;

  final String? email;
  final String? friendSince;
  final String? friendshipId;

  const FriendEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.overallBalance,
    required this.nonGroupBalance,
    required this.totalBalanceGroups,
    required this.status,
    required this.groupBreakdown,
    this.email,
    this.friendSince,
    this.friendshipId,
  });
}
