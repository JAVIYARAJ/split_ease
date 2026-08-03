part of 'activity_bloc.dart';

@immutable
sealed class ActivityEvent {}

class LoadActivities extends ActivityEvent {
  final bool isRefresh;

  LoadActivities({this.isRefresh = false});
}

class LoadMoreActivities extends ActivityEvent {}
