part of 'expense_bloc.dart';

sealed class ExpenseEvent {
  const ExpenseEvent();
}

class ExpenseInitialized extends ExpenseEvent {
  final GroupEntity group;
  final String? currentUserId;
  const ExpenseInitialized(this.group, {this.currentUserId});


}

class AmountChanged extends ExpenseEvent {
  final String amount;
  const AmountChanged(this.amount);


}

class DescriptionChanged extends ExpenseEvent {
  final String description;
  const DescriptionChanged(this.description);


}

class PayerChanged extends ExpenseEvent {
  final String userId;
  const PayerChanged(this.userId);


}

class DateChanged extends ExpenseEvent {
  final DateTime date;
  const DateChanged(this.date);


}

class SplitTypeChanged extends ExpenseEvent {
  final SplitType splitType;
  const SplitTypeChanged(this.splitType);


}

class SplitOptionChanged extends ExpenseEvent {
  final List<ExpenseSplit> splits;
  const SplitOptionChanged(this.splits);
  

}


class AddExpenseSubmitted extends ExpenseEvent {
  final String groupId;
  const AddExpenseSubmitted({required this.groupId});
  

}
