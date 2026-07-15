import 'package:equatable/equatable.dart';

class CreateExpenseParams extends Equatable {
  final String expenseScope; // 'group', 'non_group', 'personal'
  final String? groupId;
  final String description;
  final double totalAmount;
  final String? paidByUserId; // Nullable for personal
  final DateTime expenseDate;
  final String? splitType; // Nullable for personal
  final String? notes;
  final String? categoryId;
  final List<Map<String, dynamic>>? splits; // Nullable for personal

  const CreateExpenseParams({
    required this.expenseScope,
    this.groupId,
    required this.description,
    this.notes,
    this.categoryId,
    required this.totalAmount,
    this.paidByUserId,
    required this.expenseDate,
    this.splitType,
    this.splits,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'p_expense_scope': expenseScope,
      'p_category_id': categoryId,
      'p_description': description,
      'p_total_amount': totalAmount,
      'p_expense_date': expenseDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'p_expense_note': notes,
    };

    if (expenseScope != 'personal') {
      map['p_group_id'] = groupId;
      map['p_paid_by'] = paidByUserId;
      map['p_split_type'] = splitType;
      map['p_splits'] = splits;
    }

    return map;
  }

  @override
  List<Object?> get props => [
        expenseScope,
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
