import 'package:split_ease/features/friends/domain/entities/friend_request_entity.dart';

class FriendRequestModel extends FriendRequestEntity {
  const FriendRequestModel({
    required super.friendshipId,
    required super.userId,
    required super.fullName,
    super.email,
    super.avatarUrl,
    required super.requestedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      friendshipId: json['friendship_id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avtar'] as String?,
      requestedAt: DateTime.parse(json['requested_at'] as String),
    );
  }

  FriendRequestEntity toEntity() {
    return FriendRequestEntity(
      friendshipId: friendshipId,
      userId: userId,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
      requestedAt: requestedAt,
    );
  }
}
