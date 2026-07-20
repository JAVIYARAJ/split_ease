import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    final fmt = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    switch (event.filter) {
      case AnalyticsFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return (fmt.format(start), fmt.format(now));

      case AnalyticsFilter.lastWeek:
        final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
        final end = startOfThisWeek.subtract(const Duration(days: 1));
        final start = end.subtract(const Duration(days: 6));
        return (fmt.format(start), fmt.format(end));

      case AnalyticsFilter.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        return (fmt.format(start), fmt.format(now));

      case AnalyticsFilter.lastMonth:
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0); // last day of prev month
        return (fmt.format(start), fmt.format(end));

      case AnalyticsFilter.thisYear:
        final start = DateTime(now.year, 1, 1);
        return (fmt.format(start), fmt.format(now));

      case AnalyticsFilter.custom:
        final s = event.customStart != null ? fmt.format(event.customStart!) : null;
        final e = event.customEnd != null ? fmt.format(event.customEnd!) : null;
        return (s, e);
    }
  }
}
