part of 'date_bloc.dart';

class DateState extends Equatable {
  final DateTime selectedDate;
  final DateTime focusedDay;

  const DateState({
    required this.selectedDate,
    required this.focusedDay,
  });

  DateState copyWith({
    DateTime? selectedDate,
    DateTime? focusedDay,
  }) {
    return DateState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDay: focusedDay ?? this.focusedDay,
    );
  }

  @override
  List<Object> get props => [selectedDate, focusedDay];
}
