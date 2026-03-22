import 'package:equatable/equatable.dart';

class ExpenseDetailEntity extends Equatable {
  final String id;
  final String description;
  final String expenseType;
  final double totalAmount;
  final String expenseDate;
  final String createdAt;
  final ExpenseGroupEntity? group;
  final ExpenseUserEntity paidBy;
  final ExpenseUserEntity createdBy;
  final List<ExpenseSplitEntity> splits;

  const ExpenseDetailEntity({
    required this.id,
    required this.description,
    required this.expenseType,
    required this.totalAmount,
    required this.expenseDate,
    required this.createdAt,
    this.group,
    required this.paidBy,
    required this.createdBy,
    required this.splits,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        expenseType,
        totalAmount,
        expenseDate,
        createdAt,
        group,
        paidBy,
        createdBy,
        splits,
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

