part of 'activity_bloc.dart';

@immutable
sealed class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<ActivityEntity> activities;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int currentPage;

  ActivityLoaded({
    required this.activities,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
  });

  ActivityLoaded copyWith({
    List<ActivityEntity>? activities,
    bool? hasReachedMax,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return ActivityLoaded(
      activities: activities ?? this.activities,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ActivityError extends ActivityState {
  final String message;
  ActivityError(this.message);
}
