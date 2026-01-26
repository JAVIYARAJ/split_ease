import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

class GroupMemberModel extends GroupMemberEntity {
  GroupMemberModel({
    required super.memberId,
    required super.userId,
    required super.fullName,
    required super.email,
    required super.role,
    required super.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      memberId: json['member_id'] ?? '',
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      joinedAt: json['joined_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'role': role,
      'joined_at': joinedAt,
    };
  }
}
