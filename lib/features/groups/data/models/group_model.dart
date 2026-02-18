import 'package:split_ease/features/auth/data/models/user_model.dart';
import 'package:split_ease/features/groups/data/models/group_member_model.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    super.id,
    super.name,
    super.createdBy,
    super.isActive,
    super.isDeleted,
    super.updatedAt,
    super.createdAt,
    super.groupType,
    super.groupIcon,
    super.inviteCode,
    super.members,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      createdBy: json['created_by'] != null ? UserModel.fromJson(json['created_by']) : null,
      isActive: json['is_active'],
      isDeleted: json['is_deleted'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      groupType: json['group_type'],
      groupIcon: json['group_icon'],
      inviteCode: json['invite_code'],
      members: json['members'] != null
          ? (json['members'] as List).map((v) => GroupMemberModel.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['created_by'] = super.createdBy;
    data['is_active'] = super.isActive;
    data['is_deleted'] = super.isDeleted;
    data['updated_at'] = super.updatedAt;
    data['created_at'] = super.createdAt;
    data['group_type'] = super.groupType;
    data['group_icon'] = super.groupIcon;
    data['invite_code'] = super.inviteCode;
    if (super.members != null) {
      data['members'] = super.members!.map((v) => (v as GroupMemberModel).toJson()).toList();
    }
    return data;
  }
}
