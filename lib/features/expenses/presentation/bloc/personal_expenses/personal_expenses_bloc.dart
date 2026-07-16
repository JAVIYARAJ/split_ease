import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_personal_expenses.dart';
import 'personal_expenses_event.dart';
import 'personal_expenses_state.dart';

class PersonalExpensesBloc extends Bloc<PersonalExpensesEvent, PersonalExpensesState> {
  final GetPersonalExpenses _getPersonalExpenses;

  PersonalExpensesBloc({
    required GetPersonalExpenses getPersonalExpenses,
  })  : _getPersonalExpenses = getPersonalExpenses,
        super(PersonalExpensesInitial()) {
    on<LoadPersonalExpenses>(_onLoadPersonalExpenses);
  }

  Future<void> _onLoadPersonalExpenses(
    LoadPersonalExpenses event,
    Emitter<PersonalExpensesState> emit,
  ) async {
    emit(PersonalExpensesLoading());
    final result = await _getPersonalExpenses(NoParams());
    result.fold(
      (failure) => emit(PersonalExpensesError(failure.message)),
      (data) => emit(PersonalExpensesLoaded(data)),
    );
  }
}
