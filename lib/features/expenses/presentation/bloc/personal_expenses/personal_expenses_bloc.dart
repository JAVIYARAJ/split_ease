import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_personal_expenses.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_personal_expense_chart.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expense_chart_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'personal_expenses_event.dart';
import 'personal_expenses_state.dart';

class PersonalExpensesBloc extends Bloc<PersonalExpensesEvent, PersonalExpensesState> {
  final GetPersonalExpenses _getPersonalExpenses;
  final GetPersonalExpenseChart _getPersonalExpenseChart;

  PersonalExpensesBloc({
    required GetPersonalExpenses getPersonalExpenses,
    required GetPersonalExpenseChart getPersonalExpenseChart,
  })  : _getPersonalExpenses = getPersonalExpenses,
        _getPersonalExpenseChart = getPersonalExpenseChart,
        super(PersonalExpensesInitial()) {
    on<LoadPersonalExpenses>(_onLoadPersonalExpenses);
  }

  Future<void> _onLoadPersonalExpenses(
    LoadPersonalExpenses event,
    Emitter<PersonalExpensesState> emit,
  ) async {
    emit(PersonalExpensesLoading());
    
    final now = DateTime.now();
    final int currentWeekday = now.weekday;
    final startDate = now.subtract(Duration(days: currentWeekday - 1)); // Monday
    final endDate = startDate.add(const Duration(days: 6)); // Sunday

    final results = await Future.wait([
      _getPersonalExpenses(NoParams()),
      _getPersonalExpenseChart(GetPersonalExpenseChartParams(startDate: startDate, endDate: endDate)),
    ]);

    final expensesResult = results[0] as Either<Failure, PersonalExpensesEntity>;
    final chartResult = results[1] as Either<Failure, PersonalExpenseChartEntity>;

    expensesResult.fold(
      (failure) => emit(PersonalExpensesError(failure.message)),
      (expensesData) {
        chartResult.fold(
          (failure) => emit(PersonalExpensesError(failure.message)),
          (chartData) => emit(PersonalExpensesLoaded(data: expensesData, chartData: chartData)),
        );
      },
    );
  }
}
