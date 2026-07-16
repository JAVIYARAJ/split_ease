import 'package:split_ease/features/expenses/domain/entities/expense_metadata_entity.dart';
import 'package:split_ease/features/expenses/data/models/expense_category_model.dart';
import 'package:split_ease/features/expenses/data/models/expense_detail_model.dart';

class ExpenseMetadataModel extends ExpenseMetadataEntity {
  const ExpenseMetadataModel({
    required super.categories,
    required super.paymentMethods,
  });

  factory ExpenseMetadataModel.fromJson(Map<String, dynamic> json) {
    return ExpenseMetadataModel(
      categories: (json['categories'] as List?)
              ?.map((e) => ExpenseCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      paymentMethods: (json['payment_methods'] as List?)
              ?.map((e) => ExpensePaymentMethodModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
