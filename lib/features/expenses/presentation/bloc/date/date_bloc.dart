import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'date_event.dart';
part 'date_state.dart';

class DateBloc extends Bloc<DateEvent, DateState> {
  /// Logic Coordinator for the Date Selection Page.
  /// 
  /// Manages calendar selection state, keeping track of both the 
  /// selected day and the currently focused month/view.
  DateBloc() : super(DateState(selectedDate: DateTime.now(), focusedDay: DateTime.now())) {
    on<InitializeDateEvent>(_onInitializeDate);
    on<DateSelectedEvent>(_onDateSelected);
  }

  /// Sets the initial state based on provided parameters.
  void _onInitializeDate(InitializeDateEvent event, Emitter<DateState> emit) {
    final date = event.initialDate ?? DateTime.now();
    emit(state.copyWith(selectedDate: date, focusedDay: date));
  }

  void _onDateSelected(DateSelectedEvent event, Emitter<DateState> emit) {
    emit(state.copyWith(
      selectedDate: event.selectedDate,
      focusedDay: event.focusedDay,
    ));
  }
}
