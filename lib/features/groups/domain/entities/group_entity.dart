import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

class GroupEntity {
  String? id;
  String? name;
  UserEntity? createdBy;
  bool? isActive;
  bool? isDeleted;
  String? updatedAt;
  String? createdAt;
  String? groupType;
  String? groupIcon;
  String? inviteCode;
  List<GroupMemberEntity>? members;


  GroupEntity({
    this.id,
    this.name,
    this.createdBy,
    this.isActive,
    this.isDeleted,
    this.updatedAt,
    this.createdAt,
    this.groupType,
    this.groupIcon,
    this.inviteCode,
    this.members,
  });
}
