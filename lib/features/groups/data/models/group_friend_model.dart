import 'package:split_ease/features/groups/domain/entities/group_friend_entity.dart';

class GroupFriendModel extends GroupFriendEntity {
  const GroupFriendModel({
    required super.userId,
    required super.fullName,
    super.avatarUrl,
    super.email,
    required super.friendshipId,
    required super.isInGroup,
  });

  factory GroupFriendModel.fromJson(Map<String, dynamic> json) {
    return GroupFriendModel(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avtar'] as String?,
      email: json['email'] as String?,
      friendshipId: json['friendship_id'] as String,
      isInGroup: json['is_joined'] as bool? ?? false,
    );
  }
}
