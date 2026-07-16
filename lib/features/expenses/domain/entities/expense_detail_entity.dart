import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_media_entity.dart';

class ExpenseDetailEntity extends Equatable {
  final String id;
  final String description;
  final String expenseType;
  final double totalAmount;
  final String expenseDate;
  final String createdAt;
  final ExpenseGroupEntity? group;
  final ExpenseCategoryEntity? category;
  final ExpenseUserEntity paidBy;
  final ExpenseUserEntity createdBy;
  final String? notes;
  final String? updatedAt;
  final ExpenseUserEntity? updatedBy;
  final List<ExpenseSplitEntity> splits;
  final List<ExpenseMediaEntity> media;
  final bool isDeleted;
  final ExpensePaymentMethodEntity? paymentMethod;

  const ExpenseDetailEntity({
    required this.id,
    required this.description,
    this.notes,
    required this.expenseType,
    required this.totalAmount,
    required this.expenseDate,
    required this.createdAt,
    this.group,
    this.category,
    required this.paidBy,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    required this.splits,
    this.media = const [],
    this.isDeleted = false,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        notes,
        expenseType,
        totalAmount,
        expenseDate,
        createdAt,
        group,
        category,
        paidBy,
        createdBy,
        updatedAt,
        updatedBy,
        splits,
        media,
        isDeleted,
        paymentMethod,
      ];
}

class ExpenseGroupEntity extends Equatable {
  final String? id;
  final String? name;
  final String? groupIcon;

  const ExpenseGroupEntity({
    required this.id,
    required this.name,
    this.groupIcon,
  });

  @override
  List<Object?> get props => [id, name, groupIcon];
}

class ExpenseUserEntity extends Equatable {
  final String id;
  final String fullName;
  final String? avatar;

  const ExpenseUserEntity({
    required this.id,
    required this.fullName,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, fullName, avatar];
}

class ExpenseSplitEntity extends Equatable {
  final String type; // you_owe, participant, etc.
  final String? avatar;
  final double amount;
  final String userId;
  final String fullName;

  const ExpenseSplitEntity({
    required this.type,
    this.avatar,
    required this.amount,
    required this.userId,
    required this.fullName,
  });

  @override
  List<Object?> get props => [type, avatar, amount, userId, fullName];
}
class ExpenseCommentEntity extends Equatable {
  final String id;
  final String content;
  final String createdAt;
  final ExpenseUserEntity user;

  const ExpenseCommentEntity({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  @override
  List<Object?> get props => [id, content, createdAt, user];
}

class ExpensePaymentMethodEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;

  const ExpensePaymentMethodEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, icon, color];
}
