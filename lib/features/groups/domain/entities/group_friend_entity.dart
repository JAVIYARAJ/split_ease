import 'package:equatable/equatable.dart';

class GroupFriendEntity extends Equatable {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? email;
  final String friendshipId;
  final bool isInGroup;

  const GroupFriendEntity({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.email,
    required this.friendshipId,
    required this.isInGroup,
  });

  @override
  List<Object?> get props => [userId, fullName, avatarUrl, email, friendshipId, isInGroup];
}
