part of 'date_bloc.dart';

sealed class DateEvent extends Equatable {
  const DateEvent();

  @override
  List<Object> get props => [];
}

class InitializeDateEvent extends DateEvent {
  final DateTime? initialDate;

  const InitializeDateEvent({this.initialDate});

  @override
  List<Object> get props => [if (initialDate != null) initialDate!];
}

class DateSelectedEvent extends DateEvent {
  final DateTime selectedDate;
  final DateTime focusedDay;

  const DateSelectedEvent({required this.selectedDate, required this.focusedDay});

  @override
  List<Object> get props => [selectedDate, focusedDay];
}
