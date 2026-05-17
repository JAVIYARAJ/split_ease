import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';

class FriendGroupBreakdownModel extends FriendGroupBreakdownEntity {
  const FriendGroupBreakdownModel({
    required super.balance,
    required super.groupId,
    required super.groupName,
  });

  factory FriendGroupBreakdownModel.fromJson(Map<String, dynamic> json) {
    return FriendGroupBreakdownModel(
      balance: (json['balance'] as num).toDouble(),
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String,
    );
  }
}

class FriendModel extends FriendEntity {
  const FriendModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.overallBalance,
    required super.nonGroupBalance,
    required super.totalBalanceGroups,
    required super.status,
    required super.groupBreakdown,
    super.email,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['user_id'] as String,
      name: json['full_name'] as String,
      imageUrl: json['avtar'] as String?,
      email: json['email'] as String?,
      overallBalance: (json['overall_balance'] as num?)?.toDouble() ?? 0.0,
      nonGroupBalance: (json['non_group_balance'] as num?)?.toDouble() ?? 0.0,
      totalBalanceGroups: (json['total_balance_groups'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'settled',
      groupBreakdown: (json['group_breakdown'] as List<dynamic>?)
          ?.map((e) => FriendGroupBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
