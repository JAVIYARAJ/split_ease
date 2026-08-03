import 'package:equatable/equatable.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_balance_preview_entity.dart';

class GroupEntity extends Equatable {
  final String? id;
  final String? name;
  final UserEntity? createdBy;
  final String? groupType;
  final String? groupIcon;
  final String? inviteCode;
  final List<GroupMemberEntity>? members;
  final String? status;
  final double? overallBalance;
  final int? totalActiveBalances;
  final List<GroupBalancePreviewEntity>? balancePreview;
  final int? memberCount;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final double? budget;

  const GroupEntity({
    this.id,
    this.name,
    this.createdBy,
    this.groupType,
    this.groupIcon,
    this.inviteCode,
    this.members,
    this.status,
    this.overallBalance,
    this.totalActiveBalances,
    this.balancePreview,
    this.memberCount,
    this.destination,
    this.startDate,
    this.endDate,
    this.budget,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        createdBy,
        groupType,
        groupIcon,
        inviteCode,
        members,
        status,
        overallBalance,
        totalActiveBalances,
        balancePreview,
        memberCount,
        destination,
        startDate,
        endDate,
        budget,
      ];
}
