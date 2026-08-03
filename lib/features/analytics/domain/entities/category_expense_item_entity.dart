import 'package:equatable/equatable.dart';

class CategoryExpenseItemEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final double totalAmount;
  final DateTime expenseDate;
  final String expenseType; // 'group', 'personal', 'non_group'
  final String? groupName;
  final String paidBy;
  final String? paymentMethod;

  const CategoryExpenseItemEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.totalAmount,
    required this.expenseDate,
    required this.expenseType,
    this.groupName,
    required this.paidBy,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        totalAmount,
        expenseDate,
        expenseType,
        groupName,
        paidBy,
        paymentMethod,
      ];
}
