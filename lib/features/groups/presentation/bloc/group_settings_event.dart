part of 'group_settings_bloc.dart';

abstract class GroupSettingsEvent {}

class LoadGroupSettings extends GroupSettingsEvent {
  final String groupId;
  final bool hasChanges;
  LoadGroupSettings(this.groupId, {this.hasChanges = false});
}



class LeaveGroupEvent extends GroupSettingsEvent {
  final String groupId;
  LeaveGroupEvent(this.groupId);
}

class DeleteGroupEvent extends GroupSettingsEvent {
  final String groupId;
  DeleteGroupEvent(this.groupId);
}

class RemoveMemberEvent extends GroupSettingsEvent {
  final String groupId;
  final String userId;
  RemoveMemberEvent(this.groupId, this.userId);
}
