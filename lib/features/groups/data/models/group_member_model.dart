import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

class GroupMemberModel extends GroupMemberEntity {
  const GroupMemberModel({
    required super.userId,
    required super.fullName,
    required super.email,
    super.role,
    super.avtar,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      avtar: json['avtar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'role': role,
      'avtar': avtar,
    };
  }
}
