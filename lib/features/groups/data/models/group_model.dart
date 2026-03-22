import 'package:split_ease/features/auth/data/models/user_model.dart';
import 'package:split_ease/features/groups/data/models/group_member_model.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/data/models/group_balance_preview_model.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    super.id,
    super.name,
    super.createdBy,
    super.groupType,
    super.groupIcon,
    super.inviteCode,
    super.members,
    super.status,
    super.overallBalance,
    super.totalActiveBalances,
    super.balancePreview,
    super.memberCount
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      createdBy: json['created_by'] != null ? UserModel.fromJson(json['created_by']) : null,
      groupType: json['group_type'],
      groupIcon: json['group_icon'],
      inviteCode: json['invite_code'],
      members: json['members'] != null
          ? (json['members'] as List).map((v) => GroupMemberModel.fromJson(v)).toList()
          : null,
      status: json['status'],
      overallBalance: json['overall_balance'] != null ? (json['overall_balance'] is int ? (json['overall_balance'] as int).toDouble() : json['overall_balance'] as double) : null,
      totalActiveBalances: json['total_active_balances'],
      balancePreview: json['balance_preview'] != null
          ? (json['balance_preview'] as List).map((v) => GroupBalancePreviewModel.fromJson(v)).toList()
          : null,
      memberCount: json['member_count'] ?? (json['members'] != null
          ? (json['members'] as List).map((v) => GroupMemberModel.fromJson(v)).toList().length
          : null)
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['created_by'] = super.createdBy;
    data['group_type'] = super.groupType;
    data['group_icon'] = super.groupIcon;
    data['invite_code'] = super.inviteCode;
    if (super.members != null) {
      data['members'] = super.members!.map((v) => (v as GroupMemberModel).toJson()).toList();
    }
    data['status'] = super.status;
    data['overall_balance'] = super.overallBalance;
    data['total_active_balances'] = super.totalActiveBalances;
    if (super.balancePreview != null) {
      data['balance_preview'] = super.balancePreview!.map((v) => (v as GroupBalancePreviewModel).toJson()).toList();
    }
    return data;
  }
}
