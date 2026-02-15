import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';

class FriendModel extends FriendEntity {
  const FriendModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.email,
    required super.friendSince,
    required super.friendshipId,
    super.balance = 0.0,
    super.activeGroup = "Settled up",
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['user_id'] as String,
      name: json['full_name'] as String,
      imageUrl: json['avtar'] as String?,
      email: json['email'] as String?,
      friendSince: json['friend_since'] as String?,
      friendshipId: json['friendship_id'] as String?,
    );
  }

  FriendEntity toEntity() {
    return FriendEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      email: email,
      friendSince: friendSince,
      friendshipId: friendshipId,
      balance: balance,
      activeGroup: activeGroup,
    );
  }
}
