part of 'groups_bloc.dart';

@immutable
sealed class GroupsEvent {}

class LoadGroups extends GroupsEvent {}
