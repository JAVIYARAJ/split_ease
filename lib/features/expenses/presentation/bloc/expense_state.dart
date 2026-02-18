part of 'expense_bloc.dart';

enum ExpenseStatus { initial, loading, success, failure }

class ExpenseState {
  final ExpenseStatus status;
  final GroupEntity? group;
  final String amount;
  final String description;
  final String? payerId; // ID of the user who paid
  final DateTime? date;
  final SplitType splitType;
  final List<ExpenseSplit> splits;
  final String? errorMessage;

  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.group,
    this.amount = '',
    this.description = '',
    this.payerId,
    this.date,
    this.splitType = SplitType.equal,
    this.splits = const [],
    this.errorMessage,
  });

  ExpenseState copyWith({
    ExpenseStatus? status,
    GroupEntity? group,
    String? amount,
    String? description,
    String? payerId,
    DateTime? date,
    SplitType? splitType,
    List<ExpenseSplit>? splits,
    String? errorMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      group: group ?? this.group,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      payerId: payerId ?? this.payerId,
      date: date ?? this.date,
      splitType: splitType ?? this.splitType,
      splits: splits ?? this.splits,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
