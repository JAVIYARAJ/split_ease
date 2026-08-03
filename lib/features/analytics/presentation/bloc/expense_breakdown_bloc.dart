import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_expense_breakdown.dart';
import 'expense_breakdown_event.dart';
import 'expense_breakdown_state.dart';

class ExpenseBreakdownBloc extends Bloc<ExpenseBreakdownEvent, ExpenseBreakdownState> {
  final GetExpenseBreakdown getExpenseBreakdown;

  ExpenseBreakdownBloc({required this.getExpenseBreakdown}) : super(const ExpenseBreakdownState()) {
    on<LoadExpenseBreakdown>(_onLoadExpenseBreakdown);
  }

  Future<void> _onLoadExpenseBreakdown(
    LoadExpenseBreakdown event,
    Emitter<ExpenseBreakdownState> emit,
  ) async {
    final dates = _resolveDates(event);
    emit(state.copyWith(
      status: ExpenseBreakdownStatus.loading,
      activeFilter: event.filter,
      customStart: event.customStart,
      customEnd: event.customEnd,
    ));

    final result = await getExpenseBreakdown(BreakdownParams(
      startDate: dates.$1,
      endDate: dates.$2,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ExpenseBreakdownStatus.failure,
        errorMessage: failure.message,
      )),
      (breakdown) => emit(state.copyWith(
        status: ExpenseBreakdownStatus.success,
        breakdown: breakdown,
      )),
    );
  }

  /// Converts the selected [AnalyticsFilter] into a (startDate, endDate) pair
  /// formatted as 'yyyy-MM-dd', ready for the RPC.
  (String?, String?) _resolveDates(LoadExpenseBreakdown event) {
    final now = DateTime.now();

    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (event.filter) {
      case AnalyticsFilter.thisWeek:
        start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        break;

      case AnalyticsFilter.lastWeek:
        final startOfThisWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        end = startOfThisWeek.subtract(const Duration(milliseconds: 1));
        start = startOfThisWeek.subtract(const Duration(days: 7));
        break;

      case AnalyticsFilter.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;

      case AnalyticsFilter.lastMonth:
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 1).subtract(const Duration(milliseconds: 1));
        break;

      case AnalyticsFilter.thisYear:
        start = DateTime(now.year, 1, 1);
        break;

      case AnalyticsFilter.custom:
        final s = event.customStart != null
            ? DateTime(event.customStart!.year, event.customStart!.month, event.customStart!.day, 0, 0, 0).toUtc().toIso8601String()
            : null;
        final e = event.customEnd != null
            ? DateTime(event.customEnd!.year, event.customEnd!.month, event.customEnd!.day, 23, 59, 59, 999).toUtc().toIso8601String()
            : null;
        return (s, e);
    }

    return (
      DateTime(start.year, start.month, start.day, 0, 0, 0).toUtc().toIso8601String(),
      end.toUtc().toIso8601String(),
    );
  }
}
