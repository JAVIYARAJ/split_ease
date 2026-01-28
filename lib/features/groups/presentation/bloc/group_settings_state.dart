part of 'group_settings_bloc.dart';

abstract class GroupSettingsState {}

class GroupSettingsInitial extends GroupSettingsState {}

class GroupSettingsLoading extends GroupSettingsState {}

class GroupSettingsLoaded extends GroupSettingsState {
  final GroupEntity group;
  final bool hasChanges;
  GroupSettingsLoaded(this.group, {this.hasChanges = false});
}

class GroupSettingsError extends GroupSettingsState {
  final String message;
  GroupSettingsError(this.message);
}

class GroupActionSuccess extends GroupSettingsState { // For leave/delete
  final String message;
  GroupActionSuccess(this.message);
}
