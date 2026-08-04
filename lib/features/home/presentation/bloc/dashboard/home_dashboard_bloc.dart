import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
export 'package:split_ease/core/enums/app_enums.dart';
import '../../../domain/usecases/get_home_dashboard.dart';
import 'home_dashboard_event.dart';
import 'home_dashboard_state.dart';

class HomeDashboardBloc extends Bloc<HomeDashboardEvent, HomeDashboardState> {
  final GetHomeDashboard getHomeDashboard;
  final DataRefreshCubit dataRefreshCubit;
  late final StreamSubscription<DataRefreshState> _refreshSubscription;

  HomeDashboardBloc({
    required this.getHomeDashboard,
    required this.dataRefreshCubit,
  }) : super(const HomeDashboardState()) {
    on<LoadHomeDashboard>(_onLoadHomeDashboard);

    _refreshSubscription = dataRefreshCubit.stream.listen((state) {
      if (dataRefreshCubit.shouldRefresh(RefreshType.home)) {
        add(LoadHomeDashboard());
        dataRefreshCubit.clearRefresh(RefreshType.home);
      }
    });
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }

  Future<void> _onLoadHomeDashboard(
      LoadHomeDashboard event, Emitter<HomeDashboardState> emit) async {
    emit(state.copyWith(status: HomeDashboardStatus.loading));

    final result = await getHomeDashboard(GetHomeDashboardParams(
      startDate: event.startDate,
      endDate: event.endDate,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
          status: HomeDashboardStatus.failure, errorMessage: failure.message)),
      (dashboard) => emit(state.copyWith(
          status: HomeDashboardStatus.success, dashboard: dashboard)),
    );
  }
}
