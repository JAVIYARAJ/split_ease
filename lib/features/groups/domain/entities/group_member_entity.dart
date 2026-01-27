import 'dart:core';

class GroupMemberEntity {
  final String? memberId;
  final String? userId;
  final String? fullName;
  final String? email;
  final String? role;
  final String? joinedAt;
  final String? avtar;

  GroupMemberEntity({
    required this.memberId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.joinedAt,
    required this.avtar,
  });
}
