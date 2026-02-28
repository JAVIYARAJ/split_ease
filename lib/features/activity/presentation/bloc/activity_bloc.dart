import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/use_case.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/usecases/get_activity_feed_usecase.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final GetActivityFeedUseCase getActivityFeedUseCase;

  ActivityBloc({required this.getActivityFeedUseCase}) : super(ActivityInitial()) {
    on<LoadActivities>(_onLoadActivities);
  }

  Future<void> _onLoadActivities(LoadActivities event, Emitter<ActivityState> emit) async {
    emit(ActivityLoading());
    try {
      final result = await getActivityFeedUseCase(NoParams());
      result.fold(
        (failure) => emit(ActivityError(failure.message)),
        (activities) => emit(ActivityLoaded(activities)),
      );
    } catch (e) {
      emit(ActivityError("Failed to load activities"));
    }
  }
}
