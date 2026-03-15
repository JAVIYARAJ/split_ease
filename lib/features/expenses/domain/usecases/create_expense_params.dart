import 'package:equatable/equatable.dart';

class CreateExpenseParams extends Equatable {
  final String? groupId;
  final String description;
  final double totalAmount;
  final String paidByUserId;
  final DateTime expenseDate;
  final String splitType;
  final List<Map<String, dynamic>> splits;

  const CreateExpenseParams({
    this.groupId,
    required this.description,
    required this.totalAmount,
    required this.paidByUserId,
    required this.expenseDate,
    required this.splitType,
    required this.splits,
  });

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'description': description,
      'total_amount': totalAmount,
      'paid_by': paidByUserId,
      'expense_date': expenseDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'split_type': splitType,
      'splits': splits,
    };
  }

  @override
  List<Object?> get props => [
        groupId,
        description,
        totalAmount,
        paidByUserId,
        expenseDate,
        splitType,
        splits,
      ];
}
