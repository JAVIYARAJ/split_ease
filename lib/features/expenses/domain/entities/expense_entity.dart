import 'package:equatable/equatable.dart';

enum SplitType {
  equal,
  exact,
  percentage,
  shares,
}

enum ExpenseOrigin {
  group,
  friend,
  global,
  personal,
}

class ExpenseEntity extends Equatable {
  final String? id;
  final String description;
  final double amount;
  final String paidByUserId; // For simplicity, single payer initially, or primary payer
  final DateTime date;
  final String groupId;
  final SplitType splitType;
  final List<ExpenseSplit> splits;
  final String? receiptImageUrl;

  const ExpenseEntity({
    this.id,
    required this.description,
    required this.amount,
    required this.paidByUserId,
    required this.date,
    required this.groupId,
    this.splitType = SplitType.equal,
    required this.splits,
    this.receiptImageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        paidByUserId,
        date,
        groupId,
        splitType,
        splits,
        receiptImageUrl,
      ];
      
  ExpenseEntity copyWith({
    String? id,
    String? description,
    double? amount,
    String? paidByUserId,
    DateTime? date,
    String? groupId,
    SplitType? splitType,
    List<ExpenseSplit>? splits,
    String? receiptImageUrl,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidByUserId: paidByUserId ?? this.paidByUserId,
      date: date ?? this.date,
      groupId: groupId ?? this.groupId,
      splitType: splitType ?? this.splitType,
      splits: splits ?? this.splits,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
    );
  }
}

class ExpenseSplit extends Equatable {
  final String userId;
  final double amount; // Used for Exact
  final double percentage; // Used for Percentage
  final double shares; // Used for Shares

  const ExpenseSplit({
    required this.userId,
    this.amount = 0.0,
    this.percentage = 0.0,
    this.shares = 1.0,
  });

  @override
  List<Object?> get props => [userId, amount, percentage, shares];

  ExpenseSplit copyWith({
    String? userId,
    double? amount,
    double? percentage,
    double? shares,
  }) {
    return ExpenseSplit(
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      shares: shares ?? this.shares,
    );
  }
}
