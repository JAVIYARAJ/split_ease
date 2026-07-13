import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';

class ExpenseCategoryModel extends ExpenseCategoryEntity {
  const ExpenseCategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.isDefault,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isDefault: json['is_default'] as bool,
    );
  }
}
