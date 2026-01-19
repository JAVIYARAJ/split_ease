part of 'activity_bloc.dart';

@immutable
sealed class ActivityEvent {}

class LoadActivities extends ActivityEvent {}
