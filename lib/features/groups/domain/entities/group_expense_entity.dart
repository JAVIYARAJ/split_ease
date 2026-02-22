import 'package:equatable/equatable.dart';

class GroupExpenseEntity extends Equatable {
  final String expenseId;
  final String type; // "you_lent" | "you_owe"
  final String paidBy;
  final String paidByName;
  final String createdAt;
  final String description;
  final double totalAmount;
  final double yourBalanceEffect;

  const GroupExpenseEntity({
    required this.expenseId,
    required this.type,
    required this.paidBy,
    required this.paidByName,
    required this.createdAt,
    required this.description,
    required this.totalAmount,
    required this.yourBalanceEffect,
  });

  @override
  List<Object?> get props => [
        expenseId,
        type,
        paidBy,
        paidByName,
        createdAt,
        description,
        totalAmount,
        yourBalanceEffect,
      ];
}
