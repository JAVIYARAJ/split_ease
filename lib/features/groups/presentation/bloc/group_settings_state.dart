part of 'group_settings_bloc.dart';

abstract class GroupSettingsState {}

class GroupSettingsInitial extends GroupSettingsState {}

class GroupSettingsLoading extends GroupSettingsState {
  final GroupEntity? group;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;
  final double? overallBalance;
  final bool? youAreOwed;

  GroupSettingsLoading({this.group, this.currentUserId, this.memberBalances, this.overallBalance, this.youAreOwed});
}

class GroupSettingsLoaded extends GroupSettingsState {
  final GroupEntity group;
  final bool hasChanges;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;
  final double? overallBalance;
  final bool? youAreOwed;

  GroupSettingsLoaded(this.group, {
    this.hasChanges = false, 
    this.currentUserId, 
    this.memberBalances,
    this.overallBalance,
    this.youAreOwed,
  });
}

class GroupSettingsError extends GroupSettingsState {
  final String message;
  final GroupEntity? group;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;
  final double? overallBalance;
  final bool? youAreOwed;

  GroupSettingsError(this.message, {
    this.group, 
    this.currentUserId, 
    this.memberBalances,
    this.overallBalance,
    this.youAreOwed,
  });
}

class GroupActionSuccess extends GroupSettingsState { // For leave/delete
  final String message;
  final bool shouldPop;
  GroupActionSuccess(this.message, {this.shouldPop = true});
}
