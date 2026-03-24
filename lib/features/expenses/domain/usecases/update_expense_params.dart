import 'package:equatable/equatable.dart';

class UpdateExpenseParams extends Equatable {
  final String expenseId;
  final String? groupId;
  final String description;
  final double totalAmount;
  final String paidByUserId;
  final DateTime expenseDate;
  final String splitType;
  final String? notes;
  final List<Map<String, dynamic>> splits;

  const UpdateExpenseParams({
    required this.expenseId,
    this.groupId,
    required this.description,
    this.notes,
    required this.totalAmount,
    required this.paidByUserId,
    required this.expenseDate,
    required this.splitType,
    required this.splits,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_expense_id': expenseId,
      'p_group_id': groupId,
      'p_description': description,
      'p_notes': notes,
      'p_total_amount': totalAmount,
      'p_paid_by': paidByUserId,
      'p_expense_date': expenseDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'p_split_type': splitType,
      'p_splits': splits,
    };
  }

  @override
  List<Object?> get props => [
        expenseId,
        groupId,
        description,
        notes,
        totalAmount,
        paidByUserId,
        expenseDate,
        splitType,
        splits,
      ];
}
