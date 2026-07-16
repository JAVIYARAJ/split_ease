import 'package:equatable/equatable.dart';

class UpdateExpenseParams extends Equatable {
  final String expenseId;
  final String description;
  final double totalAmount;
  final String paidByUserId;
  final DateTime expenseDate;
  final String splitType;
  final String? notes;
  final String? categoryId;
  final String? paymentMethodId;
  final List<Map<String, dynamic>> splits;
  final String? groupId;
  final String expenseScope;

  const UpdateExpenseParams({
    required this.expenseId,
    required this.description,
    this.notes,
    this.categoryId,
    this.paymentMethodId,
    required this.totalAmount,
    required this.paidByUserId,
    required this.expenseDate,
    required this.splitType,
    required this.splits,
    this.groupId,
    required this.expenseScope,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_expense_id': expenseId,
      'p_description': description,
      'p_expense_note': notes,
      'p_category_id': categoryId,
      'p_payment_method_id': paymentMethodId,
      'p_total_amount': totalAmount,
      'p_paid_by': paidByUserId,
      'p_expense_date': expenseDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'p_split_type': splitType,
      'p_splits': splits,
      'p_group_id': groupId,
      'p_expense_scope': expenseScope,
    };
  }

  @override
  List<Object?> get props => [
        expenseId,
        description,
        notes,
        categoryId,
        paymentMethodId,
        totalAmount,
        paidByUserId,
        expenseDate,
        splitType,
        splits,
        groupId,
        expenseScope,
      ];
}
