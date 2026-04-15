class FriendGroupBreakdownEntity {
  final double balance;
  final String groupId;
  final String groupName;

  const FriendGroupBreakdownEntity({
    required this.balance,
    required this.groupId,
    required this.groupName,
  });

  FriendGroupBreakdownEntity copyWith({
    double? balance,
    String? groupId,
    String? groupName,
  }) {
    return FriendGroupBreakdownEntity(
      balance: balance ?? this.balance,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
    );
  }
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
  });

  FriendEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? overallBalance,
    double? nonGroupBalance,
    int? totalBalanceGroups,
    String? status,
    List<FriendGroupBreakdownEntity>? groupBreakdown,
    String? email,
  }) {
    return FriendEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      overallBalance: overallBalance ?? this.overallBalance,
      nonGroupBalance: nonGroupBalance ?? this.nonGroupBalance,
      totalBalanceGroups: totalBalanceGroups ?? this.totalBalanceGroups,
      status: status ?? this.status,
      groupBreakdown: groupBreakdown ?? this.groupBreakdown,
      email: email ?? this.email,
    );
  }
}

