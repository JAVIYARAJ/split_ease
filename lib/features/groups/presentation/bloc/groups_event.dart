part of 'groups_bloc.dart';

@immutable
sealed class GroupsEvent {}

class LoadGroups extends GroupsEvent {}

class ToggleGroupsFab extends GroupsEvent {
  final bool isExtended;
  ToggleGroupsFab(this.isExtended);
}

