import 'package:equatable/equatable.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_balance_preview_entity.dart';

class GroupEntity extends Equatable {
  final String? id;
  final String? name;
  final UserEntity? createdBy;
  final bool? isActive;
  final bool? isDeleted;
  final String? updatedAt;
  final String? createdAt;
  final String? groupType;
  final String? groupIcon;
  final String? inviteCode;
  final List<GroupMemberEntity>? members;
  final String? status;
  final double? overallBalance;
  final int? totalActiveBalances;
  final List<GroupBalancePreviewEntity>? balancePreview;


  const GroupEntity({
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
    this.status,
    this.overallBalance,
    this.totalActiveBalances,
    this.balancePreview,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        createdBy,
        isActive,
        isDeleted,
        updatedAt,
        createdAt,
        groupType,
        groupIcon,
        inviteCode,
        members,
        status,
        overallBalance,
        totalActiveBalances,
        balancePreview,
      ];
}
