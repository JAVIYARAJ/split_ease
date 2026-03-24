part of 'group_settings_bloc.dart';

abstract class GroupSettingsState {}

class GroupSettingsInitial extends GroupSettingsState {}

class GroupSettingsLoading extends GroupSettingsState {
  final GroupEntity? group;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;

  GroupSettingsLoading({this.group, this.currentUserId, this.memberBalances});
}

class GroupSettingsLoaded extends GroupSettingsState {
  final GroupEntity group;
  final bool hasChanges;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;

  GroupSettingsLoaded(this.group, {this.hasChanges = false, this.currentUserId, this.memberBalances});
}

class GroupSettingsError extends GroupSettingsState {
  final String message;
  final GroupEntity? group;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;

  GroupSettingsError(this.message, {this.group, this.currentUserId, this.memberBalances});
}

class GroupActionSuccess extends GroupSettingsState { // For leave/delete
  final String message;
  final bool shouldPop;
  GroupActionSuccess(this.message, {this.shouldPop = true});
}
