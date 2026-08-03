import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/usecases/get_activity_feed_usecase.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final GetActivityFeedUseCase getActivityFeedUseCase;
  bool _isFetchingMore = false;
  int pageLimit = 20;

  ActivityBloc({required this.getActivityFeedUseCase}) : super(ActivityInitial()) {
    on<LoadActivities>(_onLoadActivities);
    on<LoadMoreActivities>(_onLoadMoreActivities);
  }

  Future<void> _onLoadActivities(LoadActivities event, Emitter<ActivityState> emit) async {
    if (!event.isRefresh) {
      emit(ActivityLoading());
    }
    _isFetchingMore = false;
    try {
      final result = await getActivityFeedUseCase(GetActivityFeedParams(page: 1, limit: pageLimit));
      result.fold(
        (failure) => emit(ActivityError(failure.message)),
        (activities) => emit(
          ActivityLoaded(
            activities: activities,
            hasReachedMax: activities.length < pageLimit,
            isLoadingMore: false,
            currentPage: 1,
          ),
        ),
      );
    } catch (e) {
      emit(ActivityError("Failed to load activities"));
    }
  }

  Future<void> _onLoadMoreActivities(LoadMoreActivities event, Emitter<ActivityState> emit) async {
    final currentState = state;
    if (currentState is! ActivityLoaded || currentState.hasReachedMax || currentState.isLoadingMore || _isFetchingMore) {
      return;
    }

    _isFetchingMore = true;
    emit(currentState.copyWith(isLoadingMore: true));
    final nextPage = currentState.currentPage + 1;

    try {
      final result = await getActivityFeedUseCase(GetActivityFeedParams(page: nextPage, limit: pageLimit));
      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingMore: false)),
        (newActivities) {
          if (newActivities.isEmpty) {
            emit(currentState.copyWith(hasReachedMax: true, isLoadingMore: false));
          } else {
            emit(
              currentState.copyWith(
                activities: [...currentState.activities, ...newActivities],
                hasReachedMax: newActivities.length < pageLimit,
                isLoadingMore: false,
                currentPage: nextPage,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    } finally {
      _isFetchingMore = false;
    }
  }
}
