import 'package:equatable/equatable.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';
import '../../../domain/entities/home_dashboard_entity.dart';

class HomeDashboardState extends Equatable {
  final HomeDashboardStatus status;
  final HomeDashboardEntity? dashboard;
  final String errorMessage;

  const HomeDashboardState({
    this.status = HomeDashboardStatus.initial,
    this.dashboard,
    this.errorMessage = '',
  });

  HomeDashboardState copyWith({
    HomeDashboardStatus? status,
    HomeDashboardEntity? dashboard,
    String? errorMessage,
  }) {
    return HomeDashboardState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dashboard, errorMessage];
}
