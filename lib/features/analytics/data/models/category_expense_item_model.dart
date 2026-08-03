import '../../domain/entities/category_expense_item_entity.dart';

class CategoryExpenseItemModel extends CategoryExpenseItemEntity {
  const CategoryExpenseItemModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.totalAmount,
    required super.expenseDate,
    required super.expenseType,
    super.groupName,
    required super.paidBy,
    super.paymentMethod,
  });

  factory CategoryExpenseItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryExpenseItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      expenseDate: json['expense_date'] != null
          ? DateTime.tryParse(json['expense_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      expenseType: json['expense_type'] as String? ?? 'personal',
      groupName: json['group_name'] as String?,
      paidBy: json['paid_by'] as String? ?? 'You',
      paymentMethod: json['payment_method'] as String?,
    );
  }
}
