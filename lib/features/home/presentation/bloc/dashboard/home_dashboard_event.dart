import 'package:equatable/equatable.dart';

abstract class HomeDashboardEvent extends Equatable {
  const HomeDashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeDashboard extends HomeDashboardEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadHomeDashboard({this.startDate, this.endDate});

  @override
  List<Object> get props => [
        if (startDate != null) startDate!,
        if (endDate != null) endDate!,
      ];
}
