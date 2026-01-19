import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../domain/entities/activity_entity.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc() : super(ActivityInitial()) {
    on<LoadActivities>(_onLoadActivities);
  }

  Future<void> _onLoadActivities(LoadActivities event, Emitter<ActivityState> emit) async {
    emit(ActivityLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock Data
      final List<ActivityEntity> activities = [
        ActivityEntity(
          id: "1",
          type: ActivityType.settlement,
          title: "You added \"Settle all balances\".",
          subtitle: "You get back ₹608.28",
          isPositive: true,
          timestamp: DateTime(2025, 10, 9, 11, 7),
        ),
        ActivityEntity(
          id: "2",
          type: ActivityType.expense,
          title: "You added \"Aj tak amount\".",
          subtitle: "You owe ₹993.00",
          isPositive: false,
          timestamp: DateTime(2025, 10, 9, 10, 31),
        ),
        ActivityEntity(
          id: "3",
          type: ActivityType.payment,
          title: "You recorded a payment from Meet P. in \"groupname\".", 
          subtitle: "You received ₹330.00",
          isPositive: true,
          timestamp: DateTime(2025, 10, 9, 10, 17),
        ),
        ActivityEntity(
          id: "4",
          type: ActivityType.expense,
          title: "Meet K. deleted \"Mango - Bamnasa\" in \"groupname\".",
          subtitle: "You owe ₹180.00",
          isPositive: false,
          timestamp: DateTime(2025, 10, 4, 13, 41),
        ),
        ActivityEntity(
          id: "5",
          type: ActivityType.expense,
          title: "Bhruvik M. added \"First day kesar thepla\" in \"Navratri 2025\".",
          subtitle: "You owe ₹44.28",
          isPositive: false,
          timestamp: DateTime(2025, 10, 3, 23, 18),
        ),
        ActivityEntity(
          id: "6",
          type: ActivityType.addToGroup,
          title: "Meet K. added Kavan p. to the group \"Navratri 2025\".",
          isPositive: true,
          timestamp: DateTime(2025, 9, 27, 12, 53),
        ),
      ];

      emit(ActivityLoaded(activities));
    } catch (e) {
      emit(ActivityError("Failed to load activities"));
    }
  }
}
