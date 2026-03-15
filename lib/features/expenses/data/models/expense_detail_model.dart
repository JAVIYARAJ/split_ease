import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';

class ExpenseDetailModel extends ExpenseDetailEntity {
  const ExpenseDetailModel({
    required super.id,
    required super.description,
    required super.expenseType,
    required super.totalAmount,
    required super.expenseDate,
    required super.createdAt,
    super.group,
    required super.paidBy,
    required super.createdBy,
    required super.splits,
    required super.yourSummary,
    required super.monthlyTrends,
    required super.comments,
  });

  factory ExpenseDetailModel.fromJson(Map<String, dynamic> json) {
    return ExpenseDetailModel(
      id: json['id'] as String,
      description: json['description'] as String,
      expenseType: json['expense_type'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      expenseDate: json['expense_date'] as String,
      createdAt: json['created_at'] as String,
      group: json['group'] != null ? ExpenseGroupModel.fromJson(json['group']) : null,
      paidBy: ExpenseUserModel.fromJson(json['paid_by']),
      createdBy: ExpenseUserModel.fromJson(json['created_by']),
      splits: (json['splits'] as List)
          .map((e) => ExpenseSplitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      yourSummary: ExpenseSummaryModel.fromJson(json['your_summary']),
      monthlyTrends: json['monthly_trends'] != null
          ? (json['monthly_trends'] as List)
              .map((e) => ExpenseTrendModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((e) => ExpenseCommentModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class ExpenseGroupModel extends ExpenseGroupEntity {
  const ExpenseGroupModel({
    required super.id,
    required super.name,
    super.groupIcon,
  });

  factory ExpenseGroupModel.fromJson(Map<String, dynamic> json) {
    return ExpenseGroupModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      groupIcon: json['group_icon'] as String?,
    );
  }
}

class ExpenseUserModel extends ExpenseUserEntity {
  const ExpenseUserModel({
    required super.id,
    required super.fullName,
    super.avatar,
  });

  factory ExpenseUserModel.fromJson(Map<String, dynamic> json) {
    return ExpenseUserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      // API spells avatar as avtar
      avatar: json['avtar'] as String?,
    );
  }
}

class ExpenseSplitModel extends ExpenseSplitEntity {
  const ExpenseSplitModel({
    required super.type,
    super.avatar,
    required super.amount,
    required super.userId,
    required super.fullName,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      type: json['type'] as String,
      // API spells avatar as avtar
      avatar: json['avtar'] as String?,
      amount: (json['amount'] as num).toDouble(),
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
    );
  }
}

class ExpenseSummaryModel extends ExpenseSummaryEntity {
  const ExpenseSummaryModel({
    required super.youOwe,
    required super.youPaid,
    required super.netEffect,
  });

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryModel(
      youOwe: (json['you_owe'] as num).toDouble(),
      youPaid: (json['you_paid'] as num).toDouble(),
      netEffect: (json['net_effect'] as num).toDouble(),
    );
  }
}

class ExpenseTrendModel extends ExpenseTrendEntity {
  const ExpenseTrendModel({
    required super.month,
    required super.total,
  });

  factory ExpenseTrendModel.fromJson(Map<String, dynamic> json) {
    return ExpenseTrendModel(
      month: json['month'] as String,
      total: (json['total'] as num).toDouble(),
    );
  }
}

class ExpenseCommentModel extends ExpenseCommentEntity {
  const ExpenseCommentModel();

  factory ExpenseCommentModel.fromJson(Map<String, dynamic> json) {
    return const ExpenseCommentModel();
  }
}
