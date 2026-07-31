import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_expense_entity.dart';

enum RecurringExpensesStatus { initial, loading, loaded, failure }

class RecurringExpensesState extends Equatable {
  final RecurringExpensesStatus status;
  final List<RecurringExpenseEntity> items;
  final int selectedFilterIndex; // 0: All, 1: Active, 2: Paused
  final String? errorMessage;

  const RecurringExpensesState({
    this.status = RecurringExpensesStatus.initial,
    this.items = const [],
    this.selectedFilterIndex = 0,
    this.errorMessage,
  });

  double get totalMonthlyAmount {
    double total = 0.0;
    for (var item in items) {
      if (item.isPaused) continue;
      switch (item.frequency) {
        case RecurrenceFrequency.daily:
          total += item.amount * 30.4;
          break;
        case RecurrenceFrequency.weekly:
          total += item.amount * 4.33;
          break;
        case RecurrenceFrequency.monthly:
          total += item.amount;
          break;
        case RecurrenceFrequency.yearly:
          total += item.amount / 12;
          break;
      }
    }
    return total;
  }

  RecurringExpensesState copyWith({
    RecurringExpensesStatus? status,
    List<RecurringExpenseEntity>? items,
    int? selectedFilterIndex,
    String? errorMessage,
  }) {
    return RecurringExpensesState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, selectedFilterIndex, errorMessage];
}
