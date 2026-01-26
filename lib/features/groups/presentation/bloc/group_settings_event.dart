part of 'group_settings_bloc.dart';

abstract class GroupSettingsEvent {}

class LoadGroupSettings extends GroupSettingsEvent {
  final String groupId;
  LoadGroupSettings(this.groupId);
}



class LeaveGroupEvent extends GroupSettingsEvent {
  final String groupId;
  LeaveGroupEvent(this.groupId);
}

class DeleteGroupEvent extends GroupSettingsEvent {
  final String groupId;
  DeleteGroupEvent(this.groupId);
}
