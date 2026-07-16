import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';

class PersonalExpensesModel extends PersonalExpensesEntity {
  const PersonalExpensesModel({
    required super.totalSpent,
    required super.expenseCount,
    required super.expenses,
  });

  factory PersonalExpensesModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpensesModel(
      totalSpent: (json['total_spent'] as num).toDouble(),
      expenseCount: json['expense_count'] as int,
      expenses: (json['expenses'] as List)
          .map((e) => PersonalExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PersonalExpenseModel extends PersonalExpenseEntity {
  const PersonalExpenseModel({
    required super.id,
    required super.description,
    super.expenseNote,
    required super.totalAmount,
    required super.createdAt,
    super.category,
  });

  factory PersonalExpenseModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpenseModel(
      id: json['id'] as String,
      description: json['description'] as String,
      expenseNote: json['expense_note'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: json['created_at'] as String,
      category: json['category'] != null
          ? PersonalExpenseCategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PersonalExpenseCategoryModel extends PersonalExpenseCategoryEntity {
  const PersonalExpenseCategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
  });

  factory PersonalExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return PersonalExpenseCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}
