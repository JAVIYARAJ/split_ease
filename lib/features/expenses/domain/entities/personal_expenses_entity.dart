import 'package:equatable/equatable.dart';

class PersonalExpensesEntity extends Equatable {
  final double totalSpent;
  final int expenseCount;
  final List<PersonalExpenseEntity> expenses;

  const PersonalExpensesEntity({
    required this.totalSpent,
    required this.expenseCount,
    required this.expenses,
  });

  @override
  List<Object?> get props => [totalSpent, expenseCount, expenses];
}

class PersonalExpenseEntity extends Equatable {
  final String id;
  final String description;
  final String? expenseNote;
  final double totalAmount;
  final String createdAt;
  final PersonalExpenseCategoryEntity? category;

  const PersonalExpenseEntity({
    required this.id,
    required this.description,
    this.expenseNote,
    required this.totalAmount,
    required this.createdAt,
    this.category,
  });

  @override
  List<Object?> get props => [id, description, expenseNote, totalAmount, createdAt, category];
}

class PersonalExpenseCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;

  const PersonalExpenseCategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, icon, color];
}
