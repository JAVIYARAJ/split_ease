class FriendRequestEntity {
  final String friendshipId;
  final String userId;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final DateTime requestedAt;

  const FriendRequestEntity({
    required this.friendshipId,
    required this.userId,
    required this.fullName,
    this.email,
    this.avatarUrl,
    required this.requestedAt,
  });
}
