import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';

class ExpenseMetadataEntity extends Equatable {
  final List<ExpenseCategoryEntity> categories;
  final List<ExpensePaymentMethodEntity> paymentMethods;

  const ExpenseMetadataEntity({
    required this.categories,
    required this.paymentMethods,
  });

  @override
  List<Object?> get props => [categories, paymentMethods];
}
